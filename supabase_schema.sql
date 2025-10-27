-- Supabase / PostgreSQL schema untuk PaPa

-- Extension for uuid and random if not exists
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Table: users
CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  phone text,
  name text,
  email text,
  avatar_url text,
  created_at timestamptz DEFAULT now()
);

-- Table: packages
CREATE TABLE IF NOT EXISTS packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  creator_id uuid REFERENCES users(id) ON DELETE SET NULL,
  name text NOT NULL,
  description text,
  total_harga numeric NOT NULL CHECK (total_harga > 0),
  durasi_bulan int NOT NULL CHECK (durasi_bulan > 0),
  target_anggota int NOT NULL CHECK (target_anggota > 0),
  status text NOT NULL DEFAULT 'draft', -- draft, menunggu_anggota, aktif, selesai
  created_at timestamptz DEFAULT now(),
  activated_at timestamptz,
  finished_at timestamptz
);

-- Table: invitations (kode join)
CREATE TABLE IF NOT EXISTS invitations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  code text NOT NULL UNIQUE,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  expires_at timestamptz,
  created_at timestamptz DEFAULT now()
);

-- Table: package_members
CREATE TABLE IF NOT EXISTS package_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  joined_at timestamptz DEFAULT now(),
  role text DEFAULT 'member', -- member | host
  total_bayar numeric DEFAULT 0,
  UNIQUE(package_id, user_id)
);

-- Table: payments (each cicilan per anggota per bulan)
CREATE TABLE IF NOT EXISTS payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  package_id uuid REFERENCES packages(id) ON DELETE CASCADE,
  member_id uuid REFERENCES package_members(id) ON DELETE CASCADE,
  bulan_ke int NOT NULL,
  nominal numeric NOT NULL,
  due_date date,
  paid_at timestamptz,
  status text DEFAULT 'pending', -- pending | paid | overdue
  proof_url text,
  created_at timestamptz DEFAULT now()
);

-- Table: audit_logs
CREATE TABLE IF NOT EXISTS audit_logs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entity text,
  entity_id uuid,
  action text,
  payload jsonb,
  created_by uuid REFERENCES users(id),
  created_at timestamptz DEFAULT now()
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_packages_status ON packages(status);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- Function: check_and_activate_package()
-- Akan dijalankan setelah insert ke package_members
CREATE OR REPLACE FUNCTION check_and_activate_package() RETURNS trigger LANGUAGE plpgsql AS $$
DECLARE
  current_count int;
  target int;
BEGIN
  SELECT target_anggota INTO target FROM packages WHERE id = NEW.package_id;
  SELECT COUNT(*) INTO current_count FROM package_members WHERE package_id = NEW.package_id;

  IF current_count = target THEN
    -- Set package status to 'aktif' and activated_at
    UPDATE packages SET status = 'aktif', activated_at = now() WHERE id = NEW.package_id;

    -- Generate payment schedule for each member
    PERFORM generate_payment_schedule(NEW.package_id);
  ELSE
    -- Jika sebelumnya status masih draft, set ke menunggu_anggota
    UPDATE packages SET status = 'menunggu_anggota' WHERE id = NEW.package_id AND status = 'draft';
  END IF;

  RETURN NEW;
END;
$$;

-- Function: generate_payment_schedule(package_id)
CREATE OR REPLACE FUNCTION generate_payment_schedule(p_package_id uuid) RETURNS void LANGUAGE plpgsql AS $$
DECLARE
  pkg RECORD;
  member_row RECORD;
  nominal_per_member numeric;
  month int;
  due date;
BEGIN
  SELECT * INTO pkg FROM packages WHERE id = p_package_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Package not found %', p_package_id;
  END IF;

  -- calculate nominal per member per month (simple division)
  nominal_per_member := (pkg.total_harga::numeric / pkg.durasi_bulan::numeric) / pkg.target_anggota::numeric;

  -- For each member create payment rows for durasi_bulan
  FOR member_row IN SELECT id FROM package_members WHERE package_id = p_package_id LOOP
    FOR month IN 1..pkg.durasi_bulan LOOP
      due := (now()::date + (month - 1) * INTERVAL '1 month')::date;
      INSERT INTO payments(package_id, member_id, bulan_ke, nominal, due_date, status, created_at)
      VALUES (p_package_id, member_row.id, month, round(nominal_per_member::numeric, 2), due, 'pending', now());
    END LOOP;
  END LOOP;
END;
$$;

-- Trigger: after insert package_members
CREATE TRIGGER trg_check_activate
AFTER INSERT ON package_members
FOR EACH ROW EXECUTE FUNCTION check_and_activate_package();

-- Trigger: prevent duplicate activation or changes to price/duration when aktif
CREATE OR REPLACE FUNCTION prevent_modify_when_active() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  IF (TG_OP = 'UPDATE') THEN
    IF (OLD.status = 'aktif' OR OLD.status = 'selesai') THEN
      IF (NEW.total_harga <> OLD.total_harga OR NEW.durasi_bulan <> OLD.durasi_bulan) THEN
        RAISE EXCEPTION 'Tidak bisa mengubah total_harga atau durasi_bulan ketika paket sudah aktif atau selesai.';
      END IF;
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_prevent_modify_packages
BEFORE UPDATE ON packages
FOR EACH ROW EXECUTE FUNCTION prevent_modify_when_active();
