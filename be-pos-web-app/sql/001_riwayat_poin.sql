-- Riwayat poin pelanggan (append-only) + saldo awal untuk poin yang sudah ada.
-- Jalankan sekali, di dalam satu transaksi. Backup database sebelum menjalankan.
--
-- Rollback: DROP TABLE public.riwayat_poin;
--           DROP FUNCTION public.block_riwayat_poin_mutation();

BEGIN;

CREATE TABLE public.riwayat_poin (
    id_riwayat_poin uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    id_pelanggan    uuid NOT NULL REFERENCES public.pelanggan(id_pelanggan),
    jenis           varchar(30) NOT NULL
        CHECK (jenis IN ('saldo_awal', 'transaksi', 'penyesuaian', 'pembatalan_transaksi')),
    perubahan_poin  integer NOT NULL,
    poin_sebelum    integer NOT NULL CHECK (poin_sebelum >= 0),
    poin_sesudah    integer NOT NULL CHECK (poin_sesudah >= 0),
    id_transaksi    uuid REFERENCES public.transaksi(id_transaksi),
    id_user         uuid REFERENCES public.users(id_user),
    alasan          text,
    created_at      timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT riwayat_poin_saldo_check CHECK (poin_sesudah = poin_sebelum + perubahan_poin)
);

CREATE INDEX idx_riwayat_poin_pelanggan
    ON public.riwayat_poin (id_pelanggan, created_at DESC);

-- Satu transaksi hanya boleh punya satu baris 'transaksi' dan satu 'pembatalan_transaksi'.
CREATE UNIQUE INDEX uniq_riwayat_poin_transaksi
    ON public.riwayat_poin (id_transaksi, jenis)
    WHERE id_transaksi IS NOT NULL;

-- Riwayat bersifat append-only.
CREATE FUNCTION public.block_riwayat_poin_mutation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    RAISE EXCEPTION 'riwayat_poin tidak boleh diubah atau dihapus';
END;
$$;

CREATE TRIGGER trg_riwayat_poin_immutable
    BEFORE UPDATE OR DELETE ON public.riwayat_poin
    FOR EACH ROW EXECUTE FUNCTION public.block_riwayat_poin_mutation();

-- Saldo awal: satu baris per pelanggan yang sudah punya poin.
INSERT INTO public.riwayat_poin
    (id_pelanggan, jenis, perubahan_poin, poin_sebelum, poin_sesudah, alasan)
SELECT id_pelanggan, 'saldo_awal', poin_loyalitas, 0, poin_loyalitas,
       'Poin sebelum fitur riwayat poin dibuat'
FROM public.pelanggan
WHERE poin_loyalitas > 0;

COMMIT;

-- Rekonsiliasi (jalankan setelah migrasi dan kapan saja). Hasil harus kosong:
--
-- SELECT p.id_pelanggan, p.poin_loyalitas, COALESCE(r.total, 0) AS total_riwayat
-- FROM public.pelanggan p
-- LEFT JOIN (
--     SELECT id_pelanggan, SUM(perubahan_poin) AS total
--     FROM public.riwayat_poin GROUP BY id_pelanggan
-- ) r USING (id_pelanggan)
-- WHERE p.poin_loyalitas <> COALESCE(r.total, 0);
