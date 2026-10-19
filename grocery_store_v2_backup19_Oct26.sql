--
-- PostgreSQL database dump
--

\restrict t89FiQrOrpW24mNOysQXvA79cg3Qcsl2rNed3FrPGy3gr2zu5BZMRvw1ns3LBwL

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: update_detail_transaksi_timestamp(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_detail_transaksi_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.update_detail_transaksi_timestamp() OWNER TO postgres;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN    NEW.updated_at = CURRENT_TIMESTAMP;    RETURN NEW;END;$$;


ALTER FUNCTION public.update_updated_at_column() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: barang; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.barang (
    id_barang uuid DEFAULT gen_random_uuid() NOT NULL,
    nama_barang character varying(100) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    stok_dasar integer DEFAULT 0 NOT NULL,
    harga_jual_per_sd numeric(10,2) NOT NULL,
    harga_modal_per_sd numeric(10,2) NOT NULL,
    satuan_dasar character varying(10) NOT NULL,
    CONSTRAINT barang_satuan_dasar_check CHECK (((satuan_dasar)::text = ANY (ARRAY[('PCS'::character varying)::text, ('GRAM'::character varying)::text]))),
    CONSTRAINT barang_stok_dasar_check CHECK ((stok_dasar >= 0))
);


ALTER TABLE public.barang OWNER TO postgres;

--
-- Name: barang_masuk; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.barang_masuk (
    id_barang_masuk uuid DEFAULT gen_random_uuid() NOT NULL,
    id_barang uuid NOT NULL,
    qty_dasar integer NOT NULL,
    harga_beli_total numeric(10,2) NOT NULL,
    harga_beli_per_sd numeric(10,2) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT barang_masuk_harga_beli_per_sd_check CHECK ((harga_beli_per_sd >= (0)::numeric)),
    CONSTRAINT barang_masuk_harga_beli_total_check CHECK ((harga_beli_total >= (0)::numeric)),
    CONSTRAINT barang_masuk_qty_dasar_check CHECK ((qty_dasar > 0))
);


ALTER TABLE public.barang_masuk OWNER TO postgres;

--
-- Name: detail_transaksi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.detail_transaksi (
    id_detail_transaksi uuid DEFAULT gen_random_uuid() NOT NULL,
    id_transaksi uuid NOT NULL,
    id_barang uuid NOT NULL,
    nama_barang character varying(100) NOT NULL,
    harga_jual_per_sd numeric(10,2) NOT NULL,
    quantity integer NOT NULL,
    subtotal integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT detail_transaksi_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT detail_transaksi_subtotal_check CHECK ((subtotal >= 0))
);


ALTER TABLE public.detail_transaksi OWNER TO postgres;

--
-- Name: fcm_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fcm_tokens (
    id_fcm_token uuid DEFAULT gen_random_uuid() NOT NULL,
    id_user uuid NOT NULL,
    fcm_token text NOT NULL,
    device_info text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.fcm_tokens OWNER TO postgres;

--
-- Name: histori_tukar_poin; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.histori_tukar_poin (
    id_histori_tukar uuid DEFAULT gen_random_uuid() NOT NULL,
    id_pelanggan uuid,
    hadiah character varying(120) NOT NULL,
    harga_hadiah integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.histori_tukar_poin OWNER TO postgres;

--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id_notification uuid DEFAULT gen_random_uuid() NOT NULL,
    title character varying(150) NOT NULL,
    message text NOT NULL,
    notification_type character varying(50) NOT NULL,
    reference_table character varying(50),
    reference_id uuid,
    actor_user_id uuid,
    is_read boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: pelanggan; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pelanggan (
    id_pelanggan uuid DEFAULT gen_random_uuid() NOT NULL,
    nama_pelanggan character varying(100) NOT NULL,
    no_hp character varying(15),
    poin_loyalitas integer DEFAULT 0 NOT NULL,
    total_pembelian integer DEFAULT 0 NOT NULL,
    frekuensi_transaksi integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.pelanggan OWNER TO postgres;

--
-- Name: transaksi; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.transaksi (
    id_transaksi uuid DEFAULT gen_random_uuid() NOT NULL,
    kode_transaksi character varying(50) NOT NULL,
    id_pelanggan uuid,
    tipe_pelanggan character varying(15) NOT NULL,
    nama_guest character varying(50),
    id_user uuid NOT NULL,
    total_harga integer NOT NULL,
    jumlah_bayar integer NOT NULL,
    kembalian integer NOT NULL,
    status_transaksi character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT transaksi_guest_rules CHECK (((((tipe_pelanggan)::text = 'guest'::text) AND (id_pelanggan IS NULL) AND (nama_guest IS NOT NULL)) OR (((tipe_pelanggan)::text = 'member'::text) AND (id_pelanggan IS NOT NULL) AND (nama_guest IS NULL)))),
    CONSTRAINT transaksi_status_transaksi_check CHECK (((status_transaksi)::text = ANY (ARRAY[('pending'::character varying)::text, ('berhasil'::character varying)::text, ('dibatalkan'::character varying)::text])))
);


ALTER TABLE public.transaksi OWNER TO postgres;

--
-- Name: user_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_sessions (
    session_id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    refresh_hash text NOT NULL,
    user_agent text,
    ip_address inet,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    revoked_at timestamp without time zone
);


ALTER TABLE public.user_sessions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id_user uuid DEFAULT gen_random_uuid() NOT NULL,
    username character varying(50) NOT NULL,
    password text NOT NULL,
    role character varying(20) NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY (ARRAY[('owner'::character varying)::text, ('admin'::character varying)::text, ('kasir'::character varying)::text])))
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: barang; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.barang (id_barang, nama_barang, created_at, updated_at, stok_dasar, harga_jual_per_sd, harga_modal_per_sd, satuan_dasar) FROM stdin;
9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	2026-02-04 23:36:19.929226	2026-05-07 15:50:56.241005	18000	14.00	13.00	GRAM
b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	2025-05-02 13:28:55.700105	2026-05-05 10:44:49.269069	12	1000.00	750.00	PCS
fa5ba8f3-3b16-4d8d-a784-a2286ef8ee44	Bawang Putih	2026-05-05 13:06:04.075218	2026-05-05 13:06:04.075218	250	35.00	30.00	GRAM
f76d3939-fc78-460f-a05f-17f06de7dd5f	Dedak	2026-01-26 21:46:09.264955	2026-05-04 23:13:01.391995	12000	5.00	4.00	GRAM
f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	Tepung Terigu	2026-05-07 12:36:54.383173	2026-05-07 15:43:43.520117	1900	12.00	10.00	GRAM
52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	2025-04-28 12:47:21.689056	2026-05-07 15:45:58.340708	14	3500.00	2625.00	PCS
f242383f-3a55-4837-bb1a-45106102140c	Bawang Merah	2026-05-05 13:21:40.055039	2026-05-07 15:49:40.554082	100	50.00	44.00	GRAM
78228c66-13c3-4a24-b80b-13b467f2e2c4	Sampo Lifebuoy Sachet	2026-05-07 10:13:47.863343	2026-05-13 09:00:05.370237	5	500.00	400.00	PCS
75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	2025-04-27 20:04:24.978449	2026-05-13 11:36:13.165557	255	90.00	80.00	GRAM
d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	2025-12-29 22:23:05.939615	2026-05-13 11:37:03.663104	10	3000.00	2000.00	PCS
3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	2025-04-28 15:42:36.54209	2026-05-13 11:38:04.916124	13	18000.00	13500.00	PCS
d9443d7f-9196-4ae3-8245-95ce50430cfe	Tepung Tapioka/Kanji	2026-05-27 19:58:27.927413	2026-06-14 12:34:59.342366	3000	17.00	16.00	GRAM
e78f11c0-100e-4376-8a8b-ff6d8531fb35	Soklin Cair 22ml	2026-05-22 15:52:38.807143	2026-05-22 15:55:12.87282	24	500.00	400.00	PCS
41aaf721-4b71-4198-996b-aac381892ccc	Minyak Goreng Curah	2026-05-25 15:35:48.484322	2026-05-25 15:53:01.485804	3000	23.00	21.00	GRAM
a13f9c24-7863-47d7-874b-ee125e248871	Mie Sedap Soto	2026-06-14 00:28:17.097925	2026-06-14 18:26:23.011259	4	3500.00	3000.00	PCS
57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	2026-02-04 23:38:41.194263	2026-05-25 16:24:57.352524	18000	14.00	13.20	GRAM
b2994265-a215-42a3-994b-51ea4a135cba	Teh Botol Lemon Madu	2026-05-25 15:54:24.311587	2026-06-15 01:19:15.582255	2	3500.00	3000.00	PCS
1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	2025-04-28 12:45:35.705379	2026-05-25 16:46:57.823144	12	3500.00	3000.00	PCS
823267a4-2dd9-47fb-bc77-e1adcbcfce34	Gula Putih Eceran	2026-06-14 12:06:43.069857	2026-10-17 15:31:58.659446	2500	18.00	17.00	GRAM
3b31c2db-f141-4bb0-91f1-574f38f6dc44	Air Minum Botol Aqua 1.5 L	2026-10-18 07:11:09.117026	2026-10-18 07:12:05.787726	7	5000.00	4000.00	PCS
6b57b370-51c3-4481-aae2-85e72f58f717	Tepung Rose Brand	2026-05-27 20:04:41.989727	2026-05-27 20:15:47.988051	2	7000.00	6000.00	PCS
bd2dd3e7-65e0-4837-8d89-b0e18498be4b	Soklin Bubuk 215gr	2026-05-27 19:56:28.928054	2026-05-27 20:19:10.756681	20	6000.00	5000.00	PCS
27c534ab-74ba-4d53-a099-8b4ce4e6339d	Cabai Merah Keriting	2026-05-05 16:38:19.598022	2026-06-12 08:40:39.747207	190	70.00	60.00	GRAM
00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	2025-04-28 15:41:54.803812	2026-06-12 08:40:39.751872	14	3500.00	3000.00	PCS
8606af64-ec1b-450c-a962-67a852a766f4	Beras A	2026-10-18 08:32:31.533655	2026-10-18 08:33:23.070675	15000	12.00	11.00	GRAM
\.


--
-- Data for Name: barang_masuk; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.barang_masuk (id_barang_masuk, id_barang, qty_dasar, harga_beli_total, harga_beli_per_sd, created_at) FROM stdin;
1d2fc022-5e50-409a-a2a7-e0699f82d659	d8e3e01b-7236-430d-82d4-3a9d6dea0252	10	20000.00	2000.00	2025-12-29 22:23:05.939615
131c6441-03e5-4092-8498-cc093032d56b	d8e3e01b-7236-430d-82d4-3a9d6dea0252	10	20000.00	2000.00	2025-12-29 22:26:31.172025
ea4e87db-6a03-40db-9755-84d92067f6ce	f76d3939-fc78-460f-a05f-17f06de7dd5f	10000	40000.00	4.00	2026-01-26 21:46:09.264955
d1e67ace-48d7-401f-bb87-aee9bc8776d6	f76d3939-fc78-460f-a05f-17f06de7dd5f	5000	20000.00	4.00	2026-02-02 23:20:09.545739
60e51511-c8bb-4645-9dba-1327787aa444	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	25000	330000.00	13.20	2026-02-04 23:38:41.194263
9eca9db1-3603-4b67-8e23-618cc762a446	f76d3939-fc78-460f-a05f-17f06de7dd5f	3000	12000.00	4.00	2026-02-05 00:12:21.371788
d9770f56-3ffc-4f6b-8d2a-c702db28e240	9dfd11c5-0bf4-42de-b88b-1340c2249965	5000	65000.00	13.00	2026-02-05 00:22:57.334218
1c1a602e-4cd8-4eaa-89d7-484c3d13623b	9dfd11c5-0bf4-42de-b88b-1340c2249965	25000	325000.00	13.00	2026-02-04 23:36:19.929226
8c427a95-8645-445f-898f-d1cb0b4dc387	fa5ba8f3-3b16-4d8d-a784-a2286ef8ee44	250	7500.00	30.00	2026-05-05 13:06:04.075218
4c296f9e-e6f0-4a40-96f8-1e9d6f8635cd	f242383f-3a55-4837-bb1a-45106102140c	250	11000.00	44.00	2026-05-05 13:21:40.055039
96e9010e-9abc-44a4-8fb2-91a4fde56223	27c534ab-74ba-4d53-a099-8b4ce4e6339d	250	15000.00	60.00	2026-05-05 16:38:19.598022
464d7b10-40f2-49a5-bdd4-919df195cca8	75918d03-7fea-47b0-8c25-b9b726d165ce	100	8000.00	80.00	2026-05-05 16:40:24.94387
70cb6ac4-7d69-4202-bc7e-dfda97ec433b	00ad5437-d4d1-4af7-88ac-eb283c3bccac	5	15000.00	3000.00	2026-05-05 16:45:13.620389
d7441aa2-78b7-4f4e-8a92-6f98a1553db3	78228c66-13c3-4a24-b80b-13b467f2e2c4	12	4800.00	400.00	2026-05-07 10:13:47.863343
0eea202f-1862-4676-a478-9c5997f3765c	f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	1000	10000.00	10.00	2026-05-07 12:36:54.383173
a58360fa-41c9-4fd2-aa5d-0becfa02d066	f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	1000	10000.00	10.00	2026-05-07 12:39:56.519806
e41a688e-8953-40d8-addf-700c3baf25b9	e78f11c0-100e-4376-8a8b-ff6d8531fb35	12	9600.00	800.00	2026-05-22 15:52:38.807143
96d1589b-c0ad-41c3-9113-cdc0a7f98477	e78f11c0-100e-4376-8a8b-ff6d8531fb35	12	4800.00	400.00	2026-05-22 15:54:59.892881
dbb1f86d-5e43-45cb-b7e5-673cdbed2b16	41aaf721-4b71-4198-996b-aac381892ccc	2000	42000.00	21.00	2026-05-25 15:35:48.484322
bb82dae6-8786-4412-9393-5ef1fed3543e	41aaf721-4b71-4198-996b-aac381892ccc	1000	21000.00	21.00	2026-05-25 15:53:01.485804
b557220c-f228-48a1-8aeb-bec1542fcd13	b2994265-a215-42a3-994b-51ea4a135cba	3	9000.00	3000.00	2026-05-25 15:54:24.311587
d96e515b-4a9f-43d5-b26e-a36b6f912eaf	b2994265-a215-42a3-994b-51ea4a135cba	2	6000.00	3000.00	2026-05-25 15:54:52.046019
25892926-ec7f-426a-86de-d26910fa5f0a	1cfb51d0-5112-4705-a799-f60cf468dd8b	3	9000.00	3000.00	2026-05-25 16:46:40.8042
c86307a5-f108-47d3-96ed-75edb0008768	bd2dd3e7-65e0-4837-8d89-b0e18498be4b	5	20000.00	4000.00	2026-05-27 19:56:28.928054
7d78ac4b-9c0e-4ce5-88eb-b5fdd1643cd1	d9443d7f-9196-4ae3-8245-95ce50430cfe	1000	10000.00	10.00	2026-05-27 19:58:27.927413
a85695cc-23e0-4ab1-b7e0-71ae4eda4820	bd2dd3e7-65e0-4837-8d89-b0e18498be4b	2	8000.00	4000.00	2026-05-27 19:59:14.938258
5fa9b445-0d51-4d99-ac4f-6d666cfeb257	bd2dd3e7-65e0-4837-8d89-b0e18498be4b	10	40000.00	4000.00	2026-05-27 20:01:38.929362
fdce0899-8c9f-44ab-bcb6-ee5cc8f8b660	bd2dd3e7-65e0-4837-8d89-b0e18498be4b	5	25000.00	5000.00	2026-05-27 20:02:58.52193
f7ef6a4b-5f3b-4e8c-89e1-442516714a0c	6b57b370-51c3-4481-aae2-85e72f58f717	2	14000.00	7000.00	2026-05-27 20:04:41.989727
e74faf3b-044a-4215-bce9-0c0a74a43a4d	6b57b370-51c3-4481-aae2-85e72f58f717	2	12000.00	6000.00	2026-05-27 20:05:48.740154
eb92f8c7-56b0-41a0-b4a0-78ce6d4de052	a13f9c24-7863-47d7-874b-ee125e248871	5	15000.00	3000.00	2026-06-14 00:28:17.097925
7010d5fe-287f-4661-9d69-c15cacfd5dcd	823267a4-2dd9-47fb-bc77-e1adcbcfce34	5000	85000.00	17.00	2026-06-14 12:06:43.069857
b8e95168-2cb2-495b-8287-7b90b748e314	b2994265-a215-42a3-994b-51ea4a135cba	3	9000.00	3000.00	2026-06-14 12:16:15.790616
09d6314e-ff49-41b3-b96b-3cc9e28e46c0	d9443d7f-9196-4ae3-8245-95ce50430cfe	1000	10000.00	10.00	2026-06-14 12:26:31.883651
50e1b2fc-def3-4431-8cdb-03a0abb81957	d9443d7f-9196-4ae3-8245-95ce50430cfe	1000	16000.00	16.00	2026-06-14 12:30:33.956919
63a9c404-fc98-4a76-8fd1-b327d1df99e6	3b31c2db-f141-4bb0-91f1-574f38f6dc44	5	25000.00	5000.00	2026-10-18 07:11:09.117026
314aeba0-85d7-4b5e-a475-980a0e9b0048	3b31c2db-f141-4bb0-91f1-574f38f6dc44	2	8000.00	4000.00	2026-10-18 07:11:49.227923
6af73cda-4d75-4de2-8dad-77103ec77968	8606af64-ec1b-450c-a962-67a852a766f4	10000	100000.00	10.00	2026-10-18 08:32:31.533655
19e0679f-70fb-40bf-9586-d0588853da0d	8606af64-ec1b-450c-a962-67a852a766f4	5000	55000.00	11.00	2026-10-18 08:33:11.370609
\.


--
-- Data for Name: detail_transaksi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.detail_transaksi (id_detail_transaksi, id_transaksi, id_barang, nama_barang, harga_jual_per_sd, quantity, subtotal, created_at, updated_at) FROM stdin;
ebe04d75-cd97-460a-a8ed-20d8942cefa3	bbbeb388-786d-4c5a-91f9-8d19deaa72bc	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	3	10500	2025-07-06 21:15:57.013444	2025-07-06 21:15:57.013444
bb4782ed-353f-40ee-9adb-96b7bb23bdb1	bbbeb388-786d-4c5a-91f9-8d19deaa72bc	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	2	6000	2025-07-06 21:15:57.017273	2025-07-06 21:15:57.017273
6adb0b56-8037-4c84-a000-3a3f04443bd9	610d1af4-397d-41bb-9c6a-aa7102f0a902	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2025-08-19 20:13:20.546158	2025-08-19 20:13:20.546158
74a10932-f9aa-42b2-a60d-2935cc98e39e	714751dc-bdb0-49e4-bb32-124056d06141	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	5	5000	2025-08-20 09:28:22.121218	2025-08-20 09:28:22.121218
a0ce1db8-5413-4e70-9f95-cf7e297936c5	12073dbe-41ea-420f-8189-bf1983eac03e	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2025-08-20 09:30:07.536205	2025-08-20 09:30:07.536205
5795b2d6-4c5e-40c3-963b-332fc31de0ed	40041415-2e65-402a-bacc-17b0f88a3816	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	1	18000	2025-08-20 09:31:07.545205	2025-08-20 09:31:07.545205
58606956-fb0c-4cc7-8d8d-45a7e0594bf6	40041415-2e65-402a-bacc-17b0f88a3816	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	1	3500	2025-08-20 09:31:07.552925	2025-08-20 09:31:07.552925
91d042fd-8ef1-4981-a137-c20653ea60e9	40041415-2e65-402a-bacc-17b0f88a3816	52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	3500.00	1	3500	2025-08-20 09:31:07.555241	2025-08-20 09:31:07.555241
b141e91b-0c70-4038-8c92-a43fe505f5ae	40041415-2e65-402a-bacc-17b0f88a3816	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	1	3000	2025-08-20 09:31:07.557431	2025-08-20 09:31:07.557431
ef0fc45a-d3b8-44c7-8cfa-306a822fe758	5e8216a6-35ed-4094-b33d-663083945484	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	2	7000	2025-08-23 18:40:08.018889	2025-08-23 18:40:08.018889
9731b1cb-b6d7-4fc1-9b2c-07f97e9c1f82	5e8216a6-35ed-4094-b33d-663083945484	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	1	3000	2025-08-23 18:40:08.069161	2025-08-23 18:40:08.069161
e35b1f44-4250-49de-8312-d00813e011cb	7d786bea-860b-4d6e-99ac-5d901477437a	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	1	3500	2026-01-11 13:19:17.31763	2026-01-11 13:19:17.31763
da045f00-24af-403a-ba99-010c8fd1cfa1	7d786bea-860b-4d6e-99ac-5d901477437a	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	60.00	30	2000	2026-01-11 13:19:17.278119	2026-01-15 12:31:45.497004
3579568d-7746-4666-837e-6cc0b7fc1a4f	67d778d0-8a57-4214-ae24-85acb3454c64	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	60.00	30	2000	2026-01-16 13:23:10.694658	2026-01-16 13:23:10.694658
d812e07a-fd7d-4f05-9d28-929c8e40a69f	d4159518-2b50-4bca-b7bf-c502adbf9d8d	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	60.00	15	1000	2026-01-17 11:06:11.313678	2026-01-17 11:06:11.313678
1a1df55b-45e7-4530-86d1-22794873b94e	d4159518-2b50-4bca-b7bf-c502adbf9d8d	52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	3500.00	2	7000	2026-01-17 11:06:11.353767	2026-01-17 11:06:11.353767
7bf267e8-b76b-4ba6-81f9-2b5f8186616a	e8d354df-abb6-49da-b11e-ba216c2ed5e0	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	60.00	15	1000	2026-01-17 14:11:58.817936	2026-01-17 14:11:58.817936
637d3c2f-f352-49a1-ba86-fc26c633834c	e8d354df-abb6-49da-b11e-ba216c2ed5e0	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	2	7000	2026-01-17 14:11:58.843265	2026-01-17 14:11:58.843265
634f9bfb-44d0-41bd-b64c-5a5f8503efcb	c988a1e2-414b-4ac4-9b37-e60828e5d5d7	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-01-17 14:14:11.314294	2026-01-17 14:14:11.314294
4fd1add3-5f5d-4a87-b91c-f08e8a104a0f	c6b89ff5-3f96-42e0-a65f-14818aa28a34	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-01-17 14:15:43.957412	2026-01-17 14:15:43.957412
b5785f2b-45bf-446c-bf08-688511834d17	ca25c0b1-d190-454f-b35a-0e8b61ec4527	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-01-17 14:16:42.362654	2026-01-17 14:16:42.362654
365b0b6e-e562-4e59-b58b-464ac2a09a61	40d0c9ab-8366-41e6-8284-fe24aff21fcb	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-01-17 22:13:15.233874	2026-01-17 22:13:15.233874
0e317692-483b-41ce-9c16-1ef447983d44	c3fdcadb-25c2-4532-b956-ac2b14a8ef99	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-01-17 22:13:18.927039	2026-01-17 22:13:18.927039
6ebe6b83-084c-41df-8ac4-5ea4d12562f1	97f04d74-9847-470d-8a7a-4e5de635508f	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-01-17 22:13:20.281668	2026-01-17 22:13:20.281668
097f515b-fee9-48a9-8936-b7ca39e719b3	c7dfea49-a88e-4e07-96cf-29645ea7c915	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-01-17 22:13:28.139279	2026-01-17 22:13:28.139279
dea4bc58-f8ac-49cd-88f9-c46e8c381d4e	eedd4de2-3b4c-44d9-bf02-c98e638060de	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	2	6000	2026-01-17 22:18:05.671749	2026-01-17 22:18:05.671749
fca5a453-bd2f-4b57-950b-007470bf3cd0	692e4296-81b5-46ac-a158-5c6ea84c4dd3	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	2	36000	2026-01-18 13:11:00.376978	2026-01-18 13:11:00.376978
9af1ed9f-7380-4729-a628-d0a6989bd6ba	23473eaf-ffba-408b-93f7-057598a4afe8	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-01-18 13:12:11.987941	2026-01-18 13:12:11.987941
82c8635e-1aa5-41ba-9e80-77322b155781	88a995d3-e390-47d2-a1d8-196d480e638e	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-01-18 13:12:35.725993	2026-01-18 13:12:35.725993
190fc750-2e32-4cbf-a83e-260c60f3f31e	3cd8fe97-cd64-42a9-8c9d-33f3c85cf196	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	1	18000	2026-01-18 13:13:14.268812	2026-01-18 13:13:14.268812
6274f540-3ed3-4e60-b11f-2c66146a745a	12e688da-4ead-46d3-9568-fa996a5cf759	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-01-18 13:24:04.25766	2026-01-18 13:24:04.25766
d64016b6-98a5-4f56-a845-0a0cf74e3e70	87b540b2-d297-4289-b94d-fa2111d768cd	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-01-19 10:50:13.472686	2026-01-19 10:50:13.472686
8ac718b7-a86c-4a7a-affd-2b5067c7bf43	de20cd27-dddf-434e-bb4d-2fbe86e21b8d	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-01-19 10:50:13.866793	2026-01-19 10:50:13.866793
3577494b-17c7-4c1a-8421-68c5fd2d1043	f601d515-8188-4ca3-86dd-39ca82eee2c7	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	1	18000	2026-01-19 11:15:42.420053	2026-01-19 11:15:42.420053
c61c76d9-9698-447e-9ec7-6af65f5f4672	ea201b66-18f1-43ee-bee7-5545bfc6e290	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	60.00	50	3000	2026-01-26 20:51:53.661709	2026-01-26 20:51:53.661709
7c35f0bc-bc71-49af-9700-f452ac74d721	230578a4-6727-41cc-8386-9bdf2e19d6d0	f76d3939-fc78-460f-a05f-17f06de7dd5f	Dedak	5.00	3000	15000	2026-02-04 19:57:04.891042	2026-02-04 19:57:04.891042
7e8ea287-523d-4674-998a-c4d99979626d	3dda5d05-32db-4168-bb0b-e823225760da	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	5000	70000	2026-04-18 20:36:00.138248	2026-04-18 20:36:00.138248
9b94a718-b49e-4aaa-ae6a-948efac31eb5	148c31dc-41ed-4fb3-925c-d18ae1a81d62	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	2	6000	2026-05-04 23:00:02.555847	2026-05-04 23:00:02.555847
bf715e80-3486-4c20-970a-9a51eaaed190	7acd14ce-3274-4725-b8fb-667145068d20	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	2000	28000	2026-05-04 23:00:44.15856	2026-05-04 23:00:44.15856
23d56967-efe5-4118-890e-35e5c5ac3a63	570daeaa-9800-472f-be75-972d893e60d4	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1500	21000	2026-05-04 23:05:35.142294	2026-05-04 23:05:35.142294
ced6e949-cc35-4cbd-a8f5-a540b5a8d822	c7406f02-dfa0-4352-91c0-3ee4dff421ff	f76d3939-fc78-460f-a05f-17f06de7dd5f	Dedak	5.00	2000	10000	2026-05-04 23:12:36.137366	2026-05-04 23:12:36.137366
a5d1ec79-db41-47d2-9deb-1fb482865c95	0ce5689c-cd36-44c8-9217-a74d31238dda	f76d3939-fc78-460f-a05f-17f06de7dd5f	Dedak	5.00	1000	5000	2026-05-04 23:13:01.388691	2026-05-04 23:13:01.388691
2db482bc-fbdd-40b7-933f-bf3a20c24400	ded2935e-498a-471f-a4aa-1230e3e6a269	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-05-04 23:16:51.47874	2026-05-04 23:16:51.47874
1715ffd9-f4dc-4351-903f-158bc3eb1939	900b10e0-566a-4fc9-8f7a-4fbf6a7a555b	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	1	18000	2026-05-04 23:19:43.608917	2026-05-04 23:19:43.608917
d387d0cf-3687-45f6-b918-490299c472f5	7934353f-3044-4b7f-8d92-343865f8a01f	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	2	7000	2026-05-04 23:23:37.504856	2026-05-04 23:23:37.504856
392ba0c0-d63d-429d-bd23-bdef554bb3ab	b076f939-8fcc-4dfa-8c9e-753c70f4d1fa	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	1	3000	2026-05-04 23:24:35.08175	2026-05-04 23:24:35.08175
8cda24d9-4fc3-4f9a-9b7a-71f2bba3bd28	d735d4dc-df54-4c2a-8b26-c31f826351f2	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	60.00	30	2000	2026-05-04 23:25:15.859292	2026-05-04 23:25:15.859292
cc54cf0b-e5e0-4e13-a64d-e0508553a5af	19e3339a-acde-47f9-b7e1-1f86f7d119fe	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	1	18000	2026-05-04 23:26:41.895188	2026-05-04 23:26:41.895188
1d35b4fc-2332-4a95-a346-798d216c58c1	6d7e3e2a-cc71-46d7-863e-8d144bcc534d	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1500	21000	2026-05-05 10:09:08.184222	2026-05-05 10:09:08.184222
7996661e-2cd9-44c2-9c62-ed3253fb87c3	298ab402-eb83-4120-b6de-c7af9d265265	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-05-05 10:12:15.786175	2026-05-05 10:12:15.786175
fb719e5a-17ba-43a2-b7f2-81b3b717d1e0	cf86b478-d7a2-4b97-b762-23fa3e183ab2	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-05-05 10:13:46.315414	2026-05-05 10:13:46.315414
39295477-402d-4ce2-8d54-3e65b7d99769	5b193e57-699a-4049-8bdb-42dfcebaa564	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-05-05 10:42:13.921404	2026-05-05 10:42:13.921404
2d15b37f-73bc-464d-bde1-a53e4f0f9ff5	b8e22a45-d985-4057-b138-c9eede7c6bc1	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	1	1000	2026-05-05 10:43:19.586365	2026-05-05 10:43:19.586365
abc6e3b8-b85f-4e3b-9d47-ac914ac473c6	b8e22a45-d985-4057-b138-c9eede7c6bc1	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-05-05 10:43:19.59239	2026-05-05 10:43:19.59239
85335de4-8fb1-46ac-adaf-9743f239dbb1	b8e22a45-d985-4057-b138-c9eede7c6bc1	52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	3500.00	1	3500	2026-05-05 10:43:19.593629	2026-05-05 10:43:19.593629
fb33e02e-dea6-492d-b2bb-e0e1a1294687	b8e22a45-d985-4057-b138-c9eede7c6bc1	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	1	3500	2026-05-05 10:43:19.594776	2026-05-05 10:43:19.594776
49df300d-5677-4b8e-9f13-e391050349ca	42451c12-109f-4497-b3a3-81a6ce184372	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	1	1000	2026-05-05 10:44:49.266074	2026-05-05 10:44:49.266074
4b77aa9e-2de6-4669-b6a6-37f5479e784f	42451c12-109f-4497-b3a3-81a6ce184372	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-05-05 10:44:49.271731	2026-05-05 10:44:49.271731
03a45802-2989-4b5d-b79a-2f00b6fa5eb4	42451c12-109f-4497-b3a3-81a6ce184372	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	1	3500	2026-05-05 10:44:49.273386	2026-05-05 10:44:49.273386
58f1e66b-389b-4601-8ab8-0e8d93ebec4a	42451c12-109f-4497-b3a3-81a6ce184372	52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	3500.00	1	3500	2026-05-05 10:44:49.27492	2026-05-05 10:44:49.27492
76301046-b9fc-4adf-a8f6-047857e0f22d	42451c12-109f-4497-b3a3-81a6ce184372	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	1	3000	2026-05-05 10:44:49.276392	2026-05-05 10:44:49.276392
ead6dd79-00dc-45c5-a3c4-91fb4560b951	1e1a8548-24f4-48d7-bda4-9e0d69e4f542	f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	Tepung Terigu	12.00	100	1500	2026-05-07 15:43:43.516562	2026-05-07 15:43:43.516562
9b5483a6-15e5-4148-a20f-acbf6c409d67	1e1a8548-24f4-48d7-bda4-9e0d69e4f542	78228c66-13c3-4a24-b80b-13b467f2e2c4	Sampo Lifebuoy Sachet	500.00	3	1500	2026-05-07 15:43:43.522618	2026-05-07 15:43:43.522618
7eaa4a4c-76fb-4f78-975f-5dde3db6ff55	45e86bed-fd51-42db-af8c-63504456886a	52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	3500.00	2	7000	2026-05-07 15:45:58.338321	2026-05-07 15:45:58.338321
521a497e-2173-4a70-9895-67a213b8386b	45e86bed-fd51-42db-af8c-63504456886a	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	2000	28000	2026-05-07 15:45:58.343888	2026-05-07 15:45:58.343888
695b372d-6df9-4434-b3b8-0385d84db7b3	b5b39b5d-b083-49e7-b0c5-2c2398d7998e	f242383f-3a55-4837-bb1a-45106102140c	Bawang Merah	50.00	100	5000	2026-05-07 15:48:23.843775	2026-05-07 15:48:23.843775
4aecbb47-9f9e-41c9-8386-a256ed4b4a40	5d449c8e-f8a6-4164-b077-b9a94d7e41ed	f242383f-3a55-4837-bb1a-45106102140c	Bawang Merah	50.00	50	2500	2026-05-07 15:49:40.551206	2026-05-07 15:49:40.551206
2636881e-5b2a-417f-b92f-595584965aa0	1abdf55c-83bc-4cc0-800c-3fa4c9b77b4f	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	2000	28000	2026-05-07 15:50:56.238632	2026-05-07 15:50:56.238632
f27805d1-1929-4769-8825-a7fcf0ec07ec	1aac7a86-d0c7-4290-8cc8-e4a5d559c793	27c534ab-74ba-4d53-a099-8b4ce4e6339d	Cabai Merah Keriting	70.00	30	2500	2026-05-13 08:19:47.302004	2026-05-13 08:19:47.302004
ee577e34-ad40-419a-b093-415690e4c077	1aac7a86-d0c7-4290-8cc8-e4a5d559c793	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	2	7000	2026-05-13 08:19:47.324299	2026-05-13 08:19:47.324299
48589727-fe77-415b-901d-060329c42d9b	f05f1a4b-0fdc-43f9-ae07-36466e2f52ac	78228c66-13c3-4a24-b80b-13b467f2e2c4	Sampo Lifebuoy Sachet	500.00	4	2000	2026-05-13 09:00:05.368182	2026-05-13 09:00:05.368182
642faabf-833e-420c-aa39-bd2bbe1ac945	0bab7bee-4f69-4695-8e9d-a1d58bf5ce53	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	1000	14000	2026-05-13 09:00:55.269138	2026-05-13 09:00:55.269138
22c11d52-4009-447b-9d82-c27cc2172ba9	b9194dca-7e03-48fe-a8a5-7692c9a59067	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-05-13 11:36:13.147047	2026-05-13 11:36:13.147047
07b8fbcc-4f69-4954-a456-e3585509a13f	b9194dca-7e03-48fe-a8a5-7692c9a59067	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	90.00	15	1500	2026-05-13 11:36:13.16468	2026-05-13 11:36:13.16468
13ab21e7-c59c-4861-99e2-f07e958fac16	6260b0d5-a7c7-43bb-9a25-bdd9f48607b5	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	2	6000	2026-05-13 11:37:03.659916	2026-05-13 11:37:03.659916
ce75d8c8-b875-4cae-ac14-fd7c2f7969d3	79cc6426-0e17-4227-bbb5-5bb10dd0d8c3	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	1	18000	2026-05-13 11:38:04.912229	2026-05-13 11:38:04.912229
dac63390-3173-44dd-93d1-92cba31f7087	eb939faa-1aff-4121-93f7-21edf28e64b3	b2994265-a215-42a3-994b-51ea4a135cba	Teh Botol Lemon Madu	3500.00	1	3500	2026-05-25 16:23:21.22659	2026-05-25 16:23:21.22659
3358d9f7-f2f9-47f5-afc8-1997a8db2776	38cbbcf9-99d8-4d61-8b17-bae06d896b7d	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	1000	14000	2026-05-25 16:24:57.349486	2026-05-25 16:24:57.349486
5b7e78eb-762e-4bea-8e7e-71942eded3db	5979b12a-5701-4bb4-8a7e-19cedd9a2439	1cfb51d0-5112-4705-a799-f60cf468dd8b	Teh Pucuk Harum	3000.00	1	3000	2026-05-25 16:28:38.717425	2026-05-25 16:28:38.717425
a4cbcd91-8067-4d9b-a509-ee13b60f4928	92d7d391-a744-4f9e-bab8-0c4448d8a9cb	6b57b370-51c3-4481-aae2-85e72f58f717	Tepung Rose Brand	7000.00	2	14000	2026-05-27 20:15:47.972946	2026-05-27 20:15:47.972946
ba18d0cd-6bc8-4517-9640-3d583e2e23cf	92d7d391-a744-4f9e-bab8-0c4448d8a9cb	b2994265-a215-42a3-994b-51ea4a135cba	Teh Botol Lemon Madu	3500.00	4	14000	2026-05-27 20:15:47.990168	2026-05-27 20:15:47.990168
c38ca9d0-73d4-4765-ad03-4519e0308aa3	ac1c0909-14ff-45b5-8181-071a5cc1365a	bd2dd3e7-65e0-4837-8d89-b0e18498be4b	Soklin Bubuk 215gr	6000.00	2	12000	2026-05-27 20:19:10.753103	2026-05-27 20:19:10.753103
6e9ad330-545c-4d8c-a1d4-6e4d165abc77	ac1c0909-14ff-45b5-8181-071a5cc1365a	27c534ab-74ba-4d53-a099-8b4ce4e6339d	Cabai Merah Keriting	70.00	15	1500	2026-05-27 20:19:10.758901	2026-05-27 20:19:10.758901
c35e5d15-3dea-43d1-b94f-46f7ad3f2a45	df1e1692-f742-424c-a7b9-c218c7cdf38e	27c534ab-74ba-4d53-a099-8b4ce4e6339d	Cabai Merah Keriting	70.00	15	1500	2026-06-12 08:40:39.730555	2026-06-12 08:40:39.730555
cae6ab72-f5ac-40f3-8294-f1478947682b	df1e1692-f742-424c-a7b9-c218c7cdf38e	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	2	7000	2026-06-12 08:40:39.751102	2026-06-12 08:40:39.751102
b6df8ef4-4bc0-4304-838d-aa96087889f1	68459163-3e65-4265-bb68-74bfc8c9967c	823267a4-2dd9-47fb-bc77-e1adcbcfce34	Gula Putih Eceran	18.00	1000	18000	2026-06-14 18:26:22.987354	2026-06-14 18:26:22.987354
0c31914b-f446-43b2-890a-9499f7729fd1	68459163-3e65-4265-bb68-74bfc8c9967c	a13f9c24-7863-47d7-874b-ee125e248871	Mie Sedap Soto	3500.00	1	3500	2026-06-14 18:26:23.010619	2026-06-14 18:26:23.010619
2018397b-d5f2-46cb-a5f2-dd9116c3d197	0147a515-2947-48d8-9a2b-f515848e9b5f	823267a4-2dd9-47fb-bc77-e1adcbcfce34	Gula Putih Eceran	18.00	1500	27000	2026-06-15 01:19:15.56468	2026-06-15 01:19:15.56468
fac49b79-e170-4e08-937f-a9fdc7b234a2	0147a515-2947-48d8-9a2b-f515848e9b5f	b2994265-a215-42a3-994b-51ea4a135cba	Teh Botol Lemon Madu	3500.00	1	3500	2026-06-15 01:19:15.581622	2026-06-15 01:19:15.581622
\.


--
-- Data for Name: fcm_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fcm_tokens (id_fcm_token, id_user, fcm_token, device_info, created_at, updated_at) FROM stdin;
2f5c2ded-e11a-476e-be8e-491fedddb10d	6181ac3f-3415-4dc9-ba6f-69be692100fa	efq94pNogE3bVC1nEqlg8F	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	2026-10-19 12:28:22.709097	2026-10-19 13:52:55.729449
\.


--
-- Data for Name: histori_tukar_poin; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.histori_tukar_poin (id_histori_tukar, id_pelanggan, hadiah, harga_hadiah, created_at) FROM stdin;
c31b6484-a4c3-41b2-be38-6ffff5e5997e	afefb89d-9d30-4d58-bf3d-cf97053cd711	2 Soklin Bubuk Rp5000-an, 1 Panci Satu Liter	5	2026-10-19 13:03:25.538804
936b24be-599a-4dfe-b1dc-a0fcf900895c	5adb3c6c-7aad-484f-8509-52f420932591	3 Ekonomi Sabun Cuci Jeruk Nipis	2	2026-10-19 13:44:15.948733
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id_notification, title, message, notification_type, reference_table, reference_id, actor_user_id, is_read, metadata, created_at) FROM stdin;
\.


--
-- Data for Name: pelanggan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pelanggan (id_pelanggan, nama_pelanggan, no_hp, poin_loyalitas, total_pembelian, frekuensi_transaksi, created_at, updated_at) FROM stdin;
19ec6aa0-28df-4b03-92ba-418d1cc86953	pelanggan4		4	74500	9	2026-01-08 13:41:55.191617	2026-05-07 15:49:40.556119
e17eb15d-10fc-43b7-8c8c-55088b7e2547	pelanggan3	085798686543	7	92000	3	2026-01-08 13:40:14.503236	2026-05-07 15:50:56.242937
35d22c85-d308-41ee-8154-616c7e75508c	pelanggan8	\N	0	0	0	2026-05-08 08:29:00.084424	2026-05-08 08:29:08.431365
ffd18fbb-3d37-462e-9db5-a27ffbd7bc52	pelanggan5	089198686542	1	22000	3	2026-05-07 15:54:42.42597	2026-05-13 11:37:03.665472
e0ccc529-7a26-4fa7-a0e2-cd2da51a09c7	pelanggan6	\N	1	18000	1	2026-05-07 18:29:34.39002	2026-05-13 11:38:04.918167
99e0b027-cd5e-4a88-8878-42dd8d00da21	pelanggan9	081842793290	0	0	0	2026-05-25 16:24:10.118372	2026-05-25 16:24:26.739735
9a7348b4-8a70-4b5d-b6cf-1607f3e642c8	pelanggan10	081230901010	3	41500	2	2026-05-27 20:12:28.691745	2026-05-27 20:19:10.760147
e2c0e616-6a40-4dbf-98e1-d3275d407ce9	pelanggan7	089831794318	3	30500	1	2026-05-07 18:46:01.801098	2026-06-15 01:19:15.582812
a50986d1-3a5b-440b-ad2d-1bb66254beaa	pelanggan11	087898738892	0	8500	1	2026-06-12 08:07:53.905411	2026-06-16 13:54:44.410403
afefb89d-9d30-4d58-bf3d-cf97053cd711	pelanggan2	081256768764	4	100000	3	2025-06-27 05:13:10.154424	2026-10-19 13:03:25.538804
5adb3c6c-7aad-484f-8509-52f420932591	pelanggan1	081398728872	6	127000	9	2025-06-27 05:12:45.021943	2026-10-19 13:44:15.948733
\.


--
-- Data for Name: transaksi; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.transaksi (id_transaksi, kode_transaksi, id_pelanggan, tipe_pelanggan, nama_guest, id_user, total_harga, jumlah_bayar, kembalian, status_transaksi, created_at, updated_at) FROM stdin;
bbbeb388-786d-4c5a-91f9-8d19deaa72bc	TRX-AA72BC	\N	guest	guest-AA72BC	81caf204-9368-484b-b200-f9d4bde5c87b	16500	20000	3500	berhasil	2025-07-06 21:15:56.994052	2025-07-06 21:15:56.994052
610d1af4-397d-41bb-9c6a-aa7102f0a902	TRX-F0A902	\N	guest	guest-F0A902	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2025-08-19 20:13:20.51276	2025-08-19 20:13:20.51276
714751dc-bdb0-49e4-bb32-124056d06141	TRX-D06141	\N	guest	guest-D06141	81caf204-9368-484b-b200-f9d4bde5c87b	5000	5000	0	berhasil	2025-08-20 09:28:22.090494	2025-08-20 09:28:22.090494
12073dbe-41ea-420f-8189-bf1983eac03e	TRX-EAC03E	afefb89d-9d30-4d58-bf3d-cf97053cd711	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2025-08-20 09:30:07.525212	2025-08-20 09:30:07.525212
40041415-2e65-402a-bacc-17b0f88a3816	TRX-8A3816	afefb89d-9d30-4d58-bf3d-cf97053cd711	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	28000	28000	0	berhasil	2025-08-20 09:31:07.537776	2025-08-20 09:31:07.537776
5e8216a6-35ed-4094-b33d-663083945484	TRX-945484	5adb3c6c-7aad-484f-8509-52f420932591	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	10000	12000	2000	berhasil	2025-08-23 18:40:07.941975	2025-08-23 18:40:07.941975
7d786bea-860b-4d6e-99ac-5d901477437a	TRX-77437A	\N	guest	guest-77437A	81caf204-9368-484b-b200-f9d4bde5c87b	5500	7000	1500	berhasil	2026-01-11 13:19:17.270307	2026-01-15 12:37:44.250721
67d778d0-8a57-4214-ae24-85acb3454c64	TRX-454C64	\N	guest	guest-454C64	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-16 13:23:10.676943	2026-01-16 13:23:10.676943
d4159518-2b50-4bca-b7bf-c502adbf9d8d	TRX-BF9D8D	\N	guest	guest-BF9D8D	81caf204-9368-484b-b200-f9d4bde5c87b	8000	8000	0	berhasil	2026-01-17 11:06:11.298529	2026-01-17 11:06:11.298529
e8d354df-abb6-49da-b11e-ba216c2ed5e0	TRX-2ED5E0	\N	guest	guest-2ED5E0	81caf204-9368-484b-b200-f9d4bde5c87b	8000	8000	0	berhasil	2026-01-17 14:11:58.808733	2026-01-17 14:11:58.808733
c988a1e2-414b-4ac4-9b37-e60828e5d5d7	TRX-E5D5D7	\N	guest	guest-E5D5D7	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-01-17 14:14:11.297086	2026-01-17 14:14:11.297086
c6b89ff5-3f96-42e0-a65f-14818aa28a34	TRX-A28A34	\N	guest	guest-A28A34	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-01-17 14:15:43.951412	2026-01-17 14:15:43.951412
ca25c0b1-d190-454f-b35a-0e8b61ec4527	TRX-EC4527	\N	guest	guest-EC4527	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-17 14:16:42.35679	2026-01-17 14:16:42.35679
40d0c9ab-8366-41e6-8284-fe24aff21fcb	TRX-F21FCB	\N	guest	guest-F21FCB	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-17 22:13:15.223832	2026-01-17 22:13:15.223832
c3fdcadb-25c2-4532-b956-ac2b14a8ef99	TRX-A8EF99	\N	guest	guest-A8EF99	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-17 22:13:18.924602	2026-01-17 22:13:18.924602
97f04d74-9847-470d-8a7a-4e5de635508f	TRX-35508F	\N	guest	guest-35508F	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-17 22:13:20.279304	2026-01-17 22:13:20.279304
c7dfea49-a88e-4e07-96cf-29645ea7c915	TRX-A7C915	\N	guest	guest-A7C915	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-17 22:13:28.137396	2026-01-17 22:13:28.137396
eedd4de2-3b4c-44d9-bf02-c98e638060de	TRX-8060DE	\N	guest	guest-8060DE	81caf204-9368-484b-b200-f9d4bde5c87b	6000	10000	4000	berhasil	2026-01-17 22:18:05.664758	2026-01-17 22:18:05.664758
692e4296-81b5-46ac-a158-5c6ea84c4dd3	TRX-4C4DD3	e17eb15d-10fc-43b7-8c8c-55088b7e2547	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	36000	50000	14000	berhasil	2026-01-18 13:11:00.354158	2026-01-18 13:11:00.354158
23473eaf-ffba-408b-93f7-057598a4afe8	TRX-A4AFE8	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-18 13:12:11.979923	2026-01-18 13:12:11.979923
88a995d3-e390-47d2-a1d8-196d480e638e	TRX-0E638E	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-01-18 13:12:35.719097	2026-01-18 13:12:35.719097
3cd8fe97-cd64-42a9-8c9d-33f3c85cf196	TRX-5CF196	\N	guest	guest-5CF196	81caf204-9368-484b-b200-f9d4bde5c87b	18000	18000	0	berhasil	2026-01-18 13:13:14.260818	2026-01-18 13:13:14.260818
12e688da-4ead-46d3-9568-fa996a5cf759	TRX-5CF759	\N	guest	guest-5CF759	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-01-18 13:24:04.250849	2026-01-18 13:24:04.250849
87b540b2-d297-4289-b94d-fa2111d768cd	TRX-D768CD	\N	guest	guest-D768CD	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-01-19 10:50:13.452841	2026-01-19 10:50:13.452841
de20cd27-dddf-434e-bb4d-2fbe86e21b8d	TRX-E21B8D	\N	guest	guest-E21B8D	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-01-19 10:50:13.864307	2026-01-19 10:50:13.864307
f601d515-8188-4ca3-86dd-39ca82eee2c7	TRX-EEE2C7	\N	guest	guest-EEE2C7	81caf204-9368-484b-b200-f9d4bde5c87b	18000	20000	2000	berhasil	2026-01-19 11:15:42.411652	2026-01-19 11:15:42.411652
ea201b66-18f1-43ee-bee7-5545bfc6e290	TRX-C6E290	\N	guest	guest-C6E290	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-01-26 20:51:53.641921	2026-01-26 20:51:53.641921
230578a4-6727-41cc-8386-9bdf2e19d6d0	TRX-19D6D0	\N	guest	guest-19D6D0	81caf204-9368-484b-b200-f9d4bde5c87b	15000	20000	5000	berhasil	2026-02-04 19:57:04.854354	2026-02-04 19:57:04.854354
3dda5d05-32db-4168-bb0b-e823225760da	TRX-5760DA	afefb89d-9d30-4d58-bf3d-cf97053cd711	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	70000	100000	30000	berhasil	2026-04-18 20:36:00.121545	2026-04-18 20:36:00.121545
148c31dc-41ed-4fb3-925c-d18ae1a81d62	TRX-A81D62	5adb3c6c-7aad-484f-8509-52f420932591	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	6000	10000	4000	berhasil	2026-05-04 23:00:02.544922	2026-05-04 23:00:02.544922
7acd14ce-3274-4725-b8fb-667145068d20	TRX-068D20	\N	guest	guest-068D20	81caf204-9368-484b-b200-f9d4bde5c87b	28000	28000	0	berhasil	2026-05-04 23:00:44.150101	2026-05-04 23:00:44.150101
570daeaa-9800-472f-be75-972d893e60d4	TRX-3E60D4	5adb3c6c-7aad-484f-8509-52f420932591	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	21000	21000	0	berhasil	2026-05-04 23:05:35.136887	2026-05-04 23:05:35.136887
c7406f02-dfa0-4352-91c0-3ee4dff421ff	TRX-F421FF	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	10000	10000	0	berhasil	2026-05-04 23:12:36.127048	2026-05-04 23:12:36.127048
0ce5689c-cd36-44c8-9217-a74d31238dda	TRX-238DDA	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	5000	10000	5000	berhasil	2026-05-04 23:13:01.378481	2026-05-04 23:13:01.378481
ded2935e-498a-471f-a4aa-1230e3e6a269	TRX-E6A269	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-05-04 23:16:51.468289	2026-05-04 23:16:51.468289
900b10e0-566a-4fc9-8f7a-4fbf6a7a555b	TRX-7A555B	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	18000	20000	2000	berhasil	2026-05-04 23:19:43.597755	2026-05-04 23:19:43.597755
7934353f-3044-4b7f-8d92-343865f8a01f	TRX-F8A01F	\N	guest	guest-F8A01F	81caf204-9368-484b-b200-f9d4bde5c87b	7000	10000	3000	berhasil	2026-05-04 23:23:37.496713	2026-05-04 23:23:37.496713
b076f939-8fcc-4dfa-8c9e-753c70f4d1fa	TRX-F4D1FA	\N	guest	guest-F4D1FA	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-05-04 23:24:35.073597	2026-05-04 23:24:35.073597
d735d4dc-df54-4c2a-8b26-c31f826351f2	TRX-6351F2	\N	guest	guest-6351F2	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-05-04 23:25:15.850496	2026-05-04 23:25:15.850496
19e3339a-acde-47f9-b7e1-1f86f7d119fe	TRX-D119FE	\N	guest	guest-D119FE	81caf204-9368-484b-b200-f9d4bde5c87b	18000	18000	0	berhasil	2026-05-04 23:26:41.892939	2026-05-04 23:26:41.892939
6d7e3e2a-cc71-46d7-863e-8d144bcc534d	TRX-CC534D	\N	guest	guest-CC534D	81caf204-9368-484b-b200-f9d4bde5c87b	21000	21000	0	berhasil	2026-05-05 10:09:08.17131	2026-05-05 10:09:08.17131
298ab402-eb83-4120-b6de-c7af9d265265	TRX-265265	\N	guest	guest-265265	81caf204-9368-484b-b200-f9d4bde5c87b	14000	14000	0	berhasil	2026-05-05 10:12:15.777596	2026-05-05 10:12:15.777596
cf86b478-d7a2-4b97-b762-23fa3e183ab2	TRX-183AB2	\N	guest	guest-183AB2	81caf204-9368-484b-b200-f9d4bde5c87b	14000	14000	0	berhasil	2026-05-05 10:13:46.305717	2026-05-05 10:13:46.305717
5b193e57-699a-4049-8bdb-42dfcebaa564	TRX-BAA564	\N	guest	guest-BAA564	81caf204-9368-484b-b200-f9d4bde5c87b	14000	14000	0	berhasil	2026-05-05 10:42:13.912914	2026-05-05 10:42:13.912914
b8e22a45-d985-4057-b138-c9eede7c6bc1	TRX-7C6BC1	\N	guest	guest-7C6BC1	81caf204-9368-484b-b200-f9d4bde5c87b	11000	11000	0	berhasil	2026-05-05 10:43:19.578461	2026-05-05 10:43:19.578461
42451c12-109f-4497-b3a3-81a6ce184372	TRX-184372	\N	guest	guest-184372	81caf204-9368-484b-b200-f9d4bde5c87b	14000	14000	0	berhasil	2026-05-05 10:44:49.257275	2026-05-05 10:44:49.257275
1e1a8548-24f4-48d7-bda4-9e0d69e4f542	TRX-E4F542	\N	guest	guest-E4F542	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-05-07 15:43:43.508907	2026-05-07 15:43:43.508907
45e86bed-fd51-42db-af8c-63504456886a	TRX-56886A	5adb3c6c-7aad-484f-8509-52f420932591	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	35000	50000	15000	berhasil	2026-05-07 15:45:58.333356	2026-05-07 15:45:58.333356
b5b39b5d-b083-49e7-b0c5-2c2398d7998e	TRX-D7998E	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	5000	5000	0	berhasil	2026-05-07 15:48:23.838287	2026-05-07 15:48:23.838287
5d449c8e-f8a6-4164-b077-b9a94d7e41ed	TRX-7E41ED	19ec6aa0-28df-4b03-92ba-418d1cc86953	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	2500	2500	0	berhasil	2026-05-07 15:49:40.541928	2026-05-07 15:49:40.541928
1abdf55c-83bc-4cc0-800c-3fa4c9b77b4f	TRX-B77B4F	e17eb15d-10fc-43b7-8c8c-55088b7e2547	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	28000	28000	0	berhasil	2026-05-07 15:50:56.228294	2026-05-07 15:50:56.228294
1aac7a86-d0c7-4290-8cc8-e4a5d559c793	TRX-59C793	\N	guest	guest-59C793	81caf204-9368-484b-b200-f9d4bde5c87b	9500	10000	500	berhasil	2026-05-13 08:19:47.298982	2026-05-13 08:19:47.298982
f05f1a4b-0fdc-43f9-ae07-36466e2f52ac	TRX-2F52AC	ffd18fbb-3d37-462e-9db5-a27ffbd7bc52	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-05-13 09:00:05.364258	2026-05-13 09:00:05.364258
0bab7bee-4f69-4695-8e9d-a1d58bf5ce53	TRX-F5CE53	ffd18fbb-3d37-462e-9db5-a27ffbd7bc52	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	14000	20000	6000	berhasil	2026-05-13 09:00:55.259171	2026-05-13 09:00:55.259171
b9194dca-7e03-48fe-a8a5-7692c9a59067	TRX-A59067	\N	guest	guest-A59067	81caf204-9368-484b-b200-f9d4bde5c87b	4500	4500	0	berhasil	2026-05-13 11:36:13.144829	2026-05-13 11:36:13.144829
6260b0d5-a7c7-43bb-9a25-bdd9f48607b5	TRX-8607B5	ffd18fbb-3d37-462e-9db5-a27ffbd7bc52	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	6000	6000	0	berhasil	2026-05-13 11:37:03.653009	2026-05-13 11:37:03.653009
79cc6426-0e17-4227-bbb5-5bb10dd0d8c3	TRX-D0D8C3	e0ccc529-7a26-4fa7-a0e2-cd2da51a09c7	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	18000	18000	0	berhasil	2026-05-13 11:38:04.90611	2026-05-13 11:38:04.90611
eb939faa-1aff-4121-93f7-21edf28e64b3	TRX-8E64B3	\N	guest	guest-8E64B3	81caf204-9368-484b-b200-f9d4bde5c87b	3500	4000	500	berhasil	2026-05-25 16:23:21.216016	2026-05-25 16:23:21.216016
38cbbcf9-99d8-4d61-8b17-bae06d896b7d	TRX-896B7D	5adb3c6c-7aad-484f-8509-52f420932591	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	14000	14000	0	berhasil	2026-05-25 16:24:57.344962	2026-05-25 16:24:57.344962
5979b12a-5701-4bb4-8a7e-19cedd9a2439	TRX-9A2439	\N	guest	guest-9A2439	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-05-25 16:28:38.708423	2026-05-25 16:28:38.708423
92d7d391-a744-4f9e-bab8-0c4448d8a9cb	TRX-D8A9CB	9a7348b4-8a70-4b5d-b6cf-1607f3e642c8	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	28000	100000	72000	berhasil	2026-05-27 20:15:47.949403	2026-05-27 20:15:47.949403
ac1c0909-14ff-45b5-8181-071a5cc1365a	TRX-C1365A	9a7348b4-8a70-4b5d-b6cf-1607f3e642c8	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	13500	13500	0	berhasil	2026-05-27 20:19:10.742259	2026-05-27 20:19:10.742259
df1e1692-f742-424c-a7b9-c218c7cdf38e	TRX-CDF38E	a50986d1-3a5b-440b-ad2d-1bb66254beaa	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	8500	8500	0	berhasil	2026-06-12 08:40:39.707322	2026-06-12 08:40:39.707322
68459163-3e65-4265-bb68-74bfc8c9967c	TRX-C9967C	\N	guest	guest-C9967C	81caf204-9368-484b-b200-f9d4bde5c87b	21500	50000	28500	berhasil	2026-06-14 18:26:22.965455	2026-06-14 18:26:22.965455
0147a515-2947-48d8-9a2b-f515848e9b5f	TRX-8E9B5F	e2c0e616-6a40-4dbf-98e1-d3275d407ce9	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	30500	50000	19500	berhasil	2026-06-15 01:19:15.544542	2026-06-15 01:19:15.544542
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_sessions (session_id, user_id, refresh_hash, user_agent, ip_address, created_at, expires_at, revoked_at) FROM stdin;
cc194c5f-09d6-4c8a-b5fa-57759966e97d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Gu581n3Qm5CKaoP3AAOHruuhq52Em959Y9A3gBl3h0McKZ0dEDIPK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-28 12:34:57.372296	2025-12-28 13:34:56.994	\N
290cb1d8-9588-4df2-be95-40af2ba8d54c	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$YMT.mUPkNuB0A8H0Ut.T9.HBiZeIqD5GiT2L6OzoyMbyhIxz7t5VG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-29 22:14:04.871878	2025-12-29 23:32:03.452	\N
3d695224-754f-48a6-b900-56dd0c570c07	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$kO0/BpoFg/e8/pZC7oEBCeImY6fZMdM26daOO8DbJG3TLpLsnUmZK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-30 10:00:19.240194	2025-12-30 11:00:18.858	2025-12-30 10:01:09.473235
470da507-8b23-4127-a511-76b1d7f9cbb9	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$LyUU.oaK9v3JkVp4Ejl/XeBOveHYelqn4i8I9DpJaet6oj/9Boq0q	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-30 20:08:34.274382	2025-12-30 21:16:16.935	\N
7a7007ef-25cf-4a22-9fb7-794dd2bb8adb	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$9oH3z4jxlkYXcEC3RKIekeEAxDMu79JnF24M8AlDO3UrY5yQBcdXS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-15 17:29:42.606655	2026-01-15 18:29:42.227	\N
5690041c-8a99-4ccf-a22e-e9b96f860b2a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$3Sk.7BF7.ERNuXlYtsyZMuGMKfScTVUFheBhFydoRMBFKpu76jgGy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2026-01-14 05:33:37.523802	2026-01-14 06:52:44.966	\N
028eba79-fc9e-41b3-9ae1-d05f6c345584	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$JwITU2FZ9IOOrGr1WIfqauGFi2JLuyQZkkllkR2XqhBUtDbX4qx8.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-14 20:19:55.657139	2026-01-14 21:49:55.447	\N
4c148540-f0c7-4781-afc8-e16ba3fcde00	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$D.blnJe5IXXGD3J9xczcXeLQBkJ3THxk76CkjLSzT0RRSWaNhsnb6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-12 18:05:46.12614	2025-12-12 19:05:45.534	2025-12-12 18:05:59.726759
a0e19fdb-3653-4784-adca-6508af4dd7c6	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$xbqcv3rogvko2uQfRSPSR.6aeis3KC2Qunytw8mZN22GRJV4.Bv.u	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-17 14:17:30.948903	2026-01-17 15:17:30.574	\N
500b90f7-6356-4a3e-8ea8-4c0496f4ef1b	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$o2ucwnISkx7giMMnuN5DGexzX3KqJkgw2B17Vvzfa6EEyULZNyh1e	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-29 19:27:01.50068	2026-01-29 20:27:01.111	\N
058403a5-f4a8-4766-9d1f-e9fbb0fc80ab	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$SfJ4iH1KsnP9nHWr9UsDLuJR5kX55wVCGvmWjLA2MouIX5xO6gt9O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-28 12:54:10.060352	2025-12-28 13:54:09.68	\N
1247cc60-8cbc-4ab3-a147-10982d856dd6	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$m2qhWcXuEachdOxF4xYd6esr8zssNfd78MrEtJkz.O/oJSTjPJWu2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-29 22:59:47.141689	2025-12-29 23:59:46.766	2025-12-29 23:01:39.683223
179ac91a-ab90-40b5-9728-21a65de63c14	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$qDu0Ye.hIqF2S/GdXXrTYOFDd5ws/TQ2XzvlLdxnc.oCaBwBLG41O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-30 11:12:04.390821	2025-12-30 12:12:03.99	2025-12-30 11:13:27.122836
095090bd-57c4-45c6-9361-02edb43aba73	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$z2i82ddMXE9fSmEUtorMaOkziTmS9geITTVHyvSfzTRSc4AXAS22C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2026-01-06 23:32:23.092303	2026-01-07 00:43:24.283	\N
15ad6a27-1a8c-41d8-902d-ddb037128397	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$vLBkkEKzbgyXsCQcVJDVmuHlA2T9TS4tmEodprsfvlgaogeVR.ObC	PostmanRuntime/7.49.1	::1	2026-01-14 05:44:37.671272	2026-01-14 06:44:37.224	\N
fc1be594-05a5-4743-a883-63283cff6e9f	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Qb1jcax21IG8x0ql37A93OqRiv2oFkru2SBkZjBfF2c3LW.xvn9k2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-15 09:27:15.611258	2026-01-15 10:27:15.216	\N
5c3bb585-6080-4185-bd6e-5caea4945180	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$4fBAxEVpqbqiQjFNY3/ZqeNLSKnUaeqFjfz7nGDply5ef4XbnJS22	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-15 09:27:15.738538	2026-01-15 10:35:51.959	\N
666a4ba2-3615-460e-b448-cf9c24d9b87e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$7AKFshRZBcR8yaIbx4Iqn.Mq91gSbJAzDdjK5hQ1EXnQQz788oW2W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-15 11:37:14.590139	2026-01-15 13:38:00.867	\N
26bc3e90-1c31-4dd2-b90a-53feff466d29	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$2na.AyOEpZIgfthtPgvi9OjwGZTD00pX2ECRtw91CYyZNi5HyAQ/e	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-31 17:54:32.934647	2026-01-31 21:35:53.798	\N
aec81bf3-4c7c-4a52-a22a-6962c2ccd6e1	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$EefhrUSYHRlKsM/ZhH6uceIi0LbstyBlrg3i0vKOUjh8K.m4oSyJu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-17 11:09:42.944934	2026-01-17 12:27:01.717	2026-01-17 11:27:09.666604
7289a26b-56b0-48f3-a173-4b446dc34d3d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$.GjScPeS0DCALFUNL1qLmO1O5jF1rfEUlnPY9QmNGx616TiRWh1zq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-17 22:12:05.51345	2026-01-17 23:12:04.968	\N
64d8136e-a2b9-4542-bbf7-95b94e9672f6	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$M5vUsL8lk5F81.k9PdQlgOiCI.VhzIlfVmKJ7q27qwNlh9ddTPN16	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/143.0.0.0 Safari/537.36	::1	2025-12-12 13:22:31.340541	2025-12-12 14:26:18.966	\N
97ec73ff-cafb-4cbc-953e-71e05e7c24be	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$iLaoQmriR0NS1oku33TaFeHakFS51Qj4//awasoBRX/VWCEmZ4v1a	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-01-26 20:53:09.665749	2026-01-26 23:40:56.922	2026-01-26 22:42:05.589254
6d75cf2b-76b5-401d-adee-910698f5fbae	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$UXbQxLU7rLIyRced8zZg/O/l0y4Ejnn1pc1xfTW7wfGqaJvzrxV/K	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-01 06:36:48.212173	2026-02-01 08:27:26.123	\N
6c86fc72-4825-47d9-876d-4b74abb4e4ab	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$QxSm69rrsMpUmdpZieCcnu9vzZnU470dBD2wYOodHuvOzY2r2u0DS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-02 17:21:50.420458	2026-02-02 18:53:09.193	\N
4772610b-4e5b-4888-90bf-86f6f10830b4	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ZbAnQLXFWLurwzI0kIO4IOtPl05mHBIGmEfTl48W26VkFKJWG1co.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 21:47:14.468007	2026-02-08 22:49:54.63	\N
a00f10cb-e6be-43bb-bf10-6ae0df472e4c	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Jh1J4o4/xTQY4ZerDm3aNuWNF2DGrLUeUJM6gpEd.lkMaly504kzW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-02 23:15:32.194938	2026-02-03 00:19:12.146	2026-02-02 23:20:40.219466
02e10314-189f-45f5-80d5-ca54698d0f61	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$JxiFEBl38bzw94xKhFMQReOJO/9ZN4Ye3rPwvIxrGXfxIAm1B2XsO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 21:55:06.411586	2026-02-08 22:55:05.817	2026-02-08 21:55:55.9104
0d0e72c4-dd46-4b8d-8c11-175f1f6c3bb4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$R9BDNYh9br7JnF0m/Dls1eeZg2U2DGsu1lW9FyXK4jemnXFWhxrXO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-03 17:24:18.865104	2026-02-03 18:24:18.485	\N
ad0b426e-e7fb-4408-a4cf-8b956973d4fc	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$oYNopaF.h/WVdA4Oku0V9uppuKiW8/k36AFrJ8JKhirdEgCITcrb6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-04 19:08:20.196902	2026-02-04 20:08:19.82	\N
cb1b3f7f-d245-44d3-aed2-cec5af64b583	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$h8kFra7I72lT7.AknpH4EuZmQy5gD.2Vd5z3NnrFoAW3aDHSAT0HK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-09 05:42:49.087226	2026-02-09 06:42:48.698	2026-02-09 05:42:55.837525
78481e0b-9e12-4c60-a5d8-9f49b2463f09	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$gQx6cx0IM6Heuk5gCcEcaezwIVuIFeu3J2HSpiMM2DOS7YM3ScLqq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-04 23:33:53.082428	2026-02-05 01:28:45.247	\N
9915cee7-4736-4d58-90a9-bb38ff0fb741	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$1BbObJgkb1YoFugLkez.kOftX8KAZxbYDtc5vcoJ.pfHqED9bgy1O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-09 05:42:16.620426	2026-02-09 06:42:16.231	2026-02-09 05:42:57.918156
fbe9774f-79c7-4ffa-88fd-3e063d8abc62	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$6Ch9ulfqfC4btztAxwovdeAymkAr8DIbWjVRHj42ZIfYPBF4iG9zC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 20:51:14.826801	2026-02-08 21:58:26.996	\N
63e9bd55-7caf-49ed-bc4d-290d4d63d10a	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$N5C2jeADjDWQ.otg9OhkuO1aBY7jvEmQ.7AWFG9TNqlZh9b.eWvcC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-09 06:09:18.777976	2026-02-09 07:09:18.177	2026-02-09 06:09:43.979739
cdd60640-a9e0-4be7-8d4a-9c88494d3030	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$jJ6XfcEPKkTr5yMzzc0UEOKY81ntxyV6FSYPmLbVI8n16JVc38OBS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-04 20:40:51.283385	2026-02-04 21:48:00.308	\N
5100e4be-567a-4902-89ef-47b09f830675	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$77jQw3XDjChIl758BLy2FuqjqoRnDUQ5F8zYtuZLXgAPjbQjum0qC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-09 06:09:29.272443	2026-02-09 07:09:28.683	2026-02-09 06:09:46.402518
85827300-05d8-441b-8d1a-b541277ba49a	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$x0oc7SnQcIBOFjnOrgJsOOnmjRywEtZBtCJtK0ccpvj8W95eQaBlu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 21:29:21.984592	2026-02-08 22:29:21.603	\N
f015cc77-1b32-4231-82ae-272820ff8b3b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$C/fJA08Tn6ZkrYRJlH9aWeuwqoptXn8NS8xqqG/X.r/rbkslDVCOS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 21:35:09.307337	2026-02-08 22:37:12.225	\N
198152fd-c8e7-420f-b7f0-d62efd1f4439	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Rn.SASxqAy4TYHDdHpiM5OsjT7m5/2TQNrTYz6TDL6fNnxO2X5Ohu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 21:38:32.337839	2026-02-08 22:38:31.777	\N
116f8395-2949-496e-b843-55a7d9cdc5f9	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$z77Gmo6GpbSPDR78yRh4dun9DOO2BR7QGdVp.NwJZQJkE2J3WiF4G	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 20:53:39.371693	2026-02-08 22:43:33.493	\N
394f14ae-c8b4-4a58-b682-be0cade620c9	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$vCiiIYUKE/xCnFDmhdEaFuwBqqZgNhrVUIwK2EWNUfHjV5BeOsGba	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 21:44:06.476183	2026-02-08 22:44:05.821	\N
fbaf056a-829b-4d83-92d0-6e24f4340eec	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$XSBo9qoRvM9AYf6MHn9tiODOmn2DYz1XePxLX8gb.SOCRokIOKz76	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36	::1	2026-02-08 21:44:50.042294	2026-02-08 22:44:49.459	\N
7250b7f4-e160-420c-ba0f-206ec2a00d6e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$wet3xYUpDttLYUlba1XLEuGRmwpR00a7JqAmdnT2VYSlolW67A.Lm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	::1	2026-04-07 22:35:27.316139	2026-04-07 23:40:31.806	\N
3417a5a9-0190-4252-ba6b-0c1e2653f5cd	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$RpbOtH6Dt3tYSKWeWN5cZOJPYoLA080kbFZiRM5ovAQzqtgGA.9I6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-23 17:14:22.783016	2026-04-23 18:34:27.61	\N
026df471-8c2f-4b79-a491-055921bf1bfa	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$SxqTgAnoKeCjJayL.LWWl.snDpWq3Kw.Tzhk5JRx.W86aw2GQlNP6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-20 12:43:17.32061	2026-04-20 13:48:57.761	\N
c73ee568-907d-4467-a63d-9410d11a1e66	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$jTXSPsgIEAIcvsbue7EnPec3giceHEU61xKut6x3n3Mrvq.HeqfCq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-22 18:33:08.91653	2026-04-22 20:56:11.425	\N
9ed8afc7-8b10-4e11-8a71-3d7ee6b4b999	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$OHzt9qzHq23qMLl4CsWDvugH6hYy8vll9dmGWOvc/FZgZ08jlOEWS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-20 12:40:59.550917	2026-04-20 13:53:40.486	\N
175feccf-e03e-4c53-9b2c-bd2ec080c733	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$QzON6sPZ8wgtiDtdDCQh5Ov26cgmDl9kyLIZQ523JgXQQg9VUyn32	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-20 12:40:29.397976	2026-04-20 13:53:59.668	\N
4035c288-c0e5-452e-8d10-feb381b0aa57	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$awcs.qulM3AVepSGTg389O3xIg6BqF4UB0oRjzYzdtzJx9XiX51pm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	::1	2026-04-07 22:39:11.866548	2026-04-08 00:12:34.733	\N
03547a97-4a58-435c-8d63-5fc219ab369c	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$DMvL7uGnEp2g05Eb8ZR./eLkxvRjh2DWN0rtHIVKO91SEwEcNNFsa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36	::1	2026-04-07 22:37:46.407587	2026-04-08 00:21:41.577	2026-04-07 23:21:42.587197
aa3119b6-93ca-4abb-9736-c7158d6e32f4	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$fJxv/gT3ZYt/E31XvG6T/OdWuNbvYl4fTODKPSgthOkfJVJ980iAS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-18 20:21:06.182737	2026-04-18 21:35:40.453	\N
3d32eaf5-2c45-4318-8f3a-d1b3c5b81674	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$KZwZVon35jfHXt164I4tC.DaxJ8HZJjlMsf7UkcR.NNclKqXdOkBu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-22 11:01:13.297573	2026-04-22 12:07:20.154	\N
e7d20235-76de-4507-b26e-c1a804d58a98	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$PKVj0bQJhnuWhWOFSfYHiOxu/fcHY7dmdhSFLqptAeOFbKee56UV6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-22 12:32:10.027561	2026-04-22 14:08:18.37	\N
4c58e5ba-ad72-42bd-999b-74223241729a	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$xCMrDKnS0XA16Z1DE2BiCeJe9Z8xsPWM53F0sNKEswsUz.eLng766	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-23 19:42:40.835149	2026-04-23 21:04:31.6	\N
a7439eb9-8c74-4460-a2de-0b3d648caf26	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$4Xa3ruU8kUtIwjyACEf7yu5/BJL/HPrwwcRWTIVtbwjxczYDj2SWe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-24 09:09:15.213088	2026-04-24 12:34:20.118	2026-04-24 11:34:26.144747
8630456a-596a-4b28-a6d5-b930d96ed80e	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$QAjiAip7cBKJ1SEGYnSXQOSzS7Oua2KupA3flZZRrZkLZ8WZTxii2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-24 09:09:14.75338	2026-04-24 10:09:14.368	\N
3e0e37fd-5b33-4dc4-9f24-35eed7070285	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$FR0L1Rat1TXqXbHaf9nhze7rtoKIvOwf6iuVUsZ1kbg5E3.OL/jM6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-24 14:46:30.084285	2026-04-24 15:46:29.71	\N
78e58da4-1459-4bef-8df6-2bad791559d0	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Lia2KCT9TG.oih6KWwL1f.ugmYakbnk/HarvpcyFVsjPc37N5R/Ai	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-24 14:46:20.87412	2026-04-24 15:48:22.106	2026-04-24 14:49:59.372898
142b2f9d-3b4e-4efc-8814-319e4e28a71f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$Sr4lsrksiADqUnX2M0UHGOzj4RaB6eY.aUJaVdaDBoBLEMrf8SIIe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-24 14:49:14.050019	2026-04-24 15:49:13.676	2026-04-24 14:49:24.048966
1040db70-766f-496a-bc14-e174cd9b41bd	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Tf/U8A7qrjqNrEuYRx0J.ezBTIt8nGjXSRvAPurKuHgPu3Hso5ORq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-28 11:05:04.11862	2026-04-28 12:05:03.738	2026-04-28 11:05:43.497658
99251f47-00b1-40e1-9b9e-b719330a6b32	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$QfPjG2GkKwC49ewyV/RYA.MsAqUdU0qI/0icPRMLKgM2rQs86/WWG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-24 15:54:09.537165	2026-04-24 16:56:13.105	2026-04-24 15:56:30.966159
205d5f91-0f09-4cab-8a4a-76dfce4335d0	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$.SSvfuFOBP44A7tg1YpinevrkfkCjx0kaWj40CcYKJQeF25byiYBm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-25 19:01:36.328983	2026-04-25 20:01:35.86	2026-04-25 19:02:24.803643
77410a68-6da2-4cba-ad34-7714377ec1da	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$kfU1qk8rc5X7WVw3mXgXM.D9YPqk8P7TVSScNha9CLC1/N54Ph56O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-29 09:04:11.153669	2026-04-29 10:04:10.777	\N
bdbc1280-678f-4363-a08a-610d8166236c	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$KSvf.ZPhAXIgt0xPXqUNc.k3j9anVX/95lmnegD/LqqXWecrYt6aW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-26 13:32:44.576117	2026-04-26 14:52:00.985	\N
f539504e-16e9-4970-9b42-3f752355bdff	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$uJsVzh2vWpfAuQcm/byehOfFP1BrKpI9euV1czBMYzenDUr5bAogG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-26 22:31:41.749411	2026-04-26 23:36:56.46	2026-04-26 22:36:58.32764
f6f9fa01-16fa-4e55-b46e-de07e58c245a	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$CbB7HEilJPNrOZNNAVDoq.vKZ2yX2r.6XPFBdgvfF6Uhsuo7JPe1i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 02:46:48.73172	2026-05-04 04:00:16.426	\N
a13ee12e-19cd-40bd-a781-88b8a3cfea1b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$d4Xa96HGYoNb3rkA8l0WT.kiVfLjYY2Qym4f4JjRW8qSa/Pn.9oEi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-26 22:24:12.394877	2026-04-26 23:43:47.107	\N
ba758440-1a6d-46bd-b99c-4cfdca012647	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ee6aw4fAjD19VzfakAwgQ.uwZnJS5diKyUaEkaKuDN69UX76desma	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-27 12:05:45.187255	2026-04-27 13:05:44.796	\N
c6b0cb90-308e-4dea-9b8c-3dd89c2bcee5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$bVFNOqSVG7b2gdyOlYQKG./urPGcbOU1fN2cGLXuYtU1BV8rtoAK2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-29 20:01:05.424582	2026-04-29 21:51:41.797	\N
6df5632e-e1cd-4dba-a3f5-f533892f7871	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$8UGAb/CVP8ULrmUP0l.7UuqK7wIhMJ/vvDvK.z/OQfsnS7K1TbzHS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-29 09:15:24.534219	2026-04-29 11:05:29.873	\N
4c3cc178-6d66-4f43-9fcb-0edf7275f8cd	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$nCmX8nkvwAOG/OLv0oV.huzZ.FfadHu2BPtUYGF6Tkm.Zk6h23u3S	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-29 17:47:03.6332	2026-04-29 18:47:03.253	\N
37bf99e7-b05f-4134-bf20-17b17e58928d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$c6Tt6A6zErVybwkC/K7tS.Y0gpjrxHcqPysmZFKnLQVeNSOXw9nI2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-27 17:04:35.978379	2026-04-27 19:40:46.886	\N
46fafc22-3883-478b-84b2-65e4ae1c7879	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$bQVkphB2WuEn7AJ8MQ2PBuYmbh/IbfU/eqjPc297yPOAMU2d2LOdu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-29 17:47:04.063531	2026-04-29 19:11:27.776	\N
8ed27f09-f42d-4c66-bd67-2ed5354d335f	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$5jkGvxtGC7dVDTIQFUQna.WpR3Ht0fJf/Oc0Pyb.kb7O6usjaYPea	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-26 16:56:27.971064	2026-04-26 23:23:35.041	2026-04-26 22:24:04.919032
f70f4432-b897-4749-b7a8-504d312219ab	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$xIC2CF4m0DItncAAU4T1geP22BUclLfo6NhA5leUF9UbU8ujtmfF2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-03 18:16:40.886197	2026-05-03 20:33:40.148	\N
08089978-09d6-4d70-88c4-c5dab6d469c7	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$vtpBwbXPGNIhUCylsqHAsemFF4BIP70QsWQvlsnnhryAT.Q3lvrtG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-27 19:09:29.990992	2026-04-27 21:08:48.575	\N
6ba77738-4549-4b77-b144-29cd51a9567e	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$gpR.2y59cFz.2e0du/29Xu.1IHOwVtY8BqQLpkg7FDSgD0Vu.KqRm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 01:34:54.078829	2026-05-04 02:37:29.107	\N
dcb64fee-b710-4a38-b79a-18431d9a5ef7	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$soDmFPQorvErsRh.YTs7/.ngFhJctk3iHQvee6GfInbMnuynJRPj.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-30 10:41:31.774627	2026-04-30 12:15:17.094	\N
a973516a-9907-42f6-9860-65e46b629d3a	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$zcguPHdULCmDsTAOLI7i4uQT92RDynoWu5scmDTz6Ei4kJsDyVvia	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-04-30 12:37:18.122619	2026-04-30 13:37:17.748	\N
95600764-a1be-4120-8380-987ef57542d8	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$NhJS6d6yz.M/FNSrSj58LOlHeELs18jWvl5XnOICIeCe7MzZnY73m	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:00:02.160746	2026-05-04 12:00:01.76	2026-05-04 11:00:40.540806
69b059b1-f43d-4e63-a3e3-382a7f26e4c7	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$jhsbjde1varZeQ2Fe7iOp.mrYX9l1noFggjC5CX93R8pEX0aPSfle	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 02:50:31.7851	2026-05-04 03:50:31.411	\N
616a513e-25a4-4652-8c81-76a649b9cf85	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$p4LKjvuIwBRvdj0vuMrZKevqqKkgk0pSf5FU2P7N0mRMTkNegmvz2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:00:49.344982	2026-05-04 12:00:48.972	\N
44a6cdfd-99a5-4a63-a476-18b2fbacfb2b	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$8XU9bwZkNJUMZMHJGzNXVOc3DjWR7zuuklcWCX8FRDpNJwZiMkH0W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:07:11.430893	2026-05-04 12:13:33.431	2026-05-04 11:15:18.152844
5162c153-4ad5-410d-a152-c55a1d373a94	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$aRXw8zNPdrpsBDvcdqEt6OOJ7/I5RKOinJkYkIPf1PSvgi2Oi3BA2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 10:55:31.436287	2026-05-04 12:11:49.921	\N
7219cb46-90bc-49e1-a052-ef723f1db245	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$m23h05I2S46yqgSSFewCnuk8CGLMKI.ciyL7Iu3IHco7A.kZCsJcS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 12:10:48.303167	2026-05-04 13:47:27.156	\N
b5b2ad10-2e4d-4f4c-9a7b-78e9bc33f8ac	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$CTKmlxAWuAj5G.ATyYoyOufmbaNXtaLBnaqTwKv3vlslyiOvRNmBm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:38:17.215434	2026-05-04 14:02:01.318	\N
02e89677-df9f-493f-a179-62ca00ae9e65	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$sbb5ua0/8j842T8mBMTrxOzUAdjWM/igfVYEGjA/335o6jfiM5W9.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 12:31:09.770024	2026-05-05 14:24:10.428	\N
0c73c3de-d73e-4e59-aaec-a123b9e6df7e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$gr0vhM/5c3anlYslRKKkP.XczlC.RQLsOYqGAc.65TzDyhn/I1teu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 00:09:17.220967	2026-05-05 01:54:51.561	\N
6860d2db-db03-435f-b224-253909aeb04d	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$WZ7lW5XdeeUOi1QNgp7P0.yp2B/xmxuCuUjebJMODENa8wKgGTpVS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 16:48:47.164537	2026-05-04 19:51:57.492	\N
8ee8c29f-9864-438d-9bf3-b6c71bc8d696	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$huanjJWZzRCN0pT/s6LJIeJKpCPlHVY8P9WOXMk/ul5GcPBFayUGq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 20:48:54.812079	2026-05-04 21:50:55.451	\N
9a545765-d46e-416f-9a61-1bbbc59dafb6	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$BQKSCQQ0S2W00RHEGWzBl.Q4un9jq8C/QCWyXTqqHLoH5ByFRaECa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 00:08:51.987913	2026-05-05 01:57:47.107	2026-05-05 00:57:50.102452
cdac04ec-df8c-4aed-9c6d-a36825b98f08	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$.tYIcS8CYal3xgusthlOLOBeUMkwzRGgUNQDJyEMinEFWwKYykz8e	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 08:39:45.247449	2026-05-05 09:39:44.871	\N
35b3a973-55bf-4321-9cf1-607a00759eb6	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$0F7Ixspu9r6PnlPmFuVJxOykPzBrorr6JlaueglsmZUnheZwAGzZO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 22:55:51.743459	2026-05-05 00:16:37.595	\N
a80f76f7-a303-40a2-9ab9-5248a72dc0f3	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$HZjX7KdPxJ4QoE4zFzGCqeFTIHYAe4WwL/MFeVkZQuuht8ad9fwle	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 10:08:30.665037	2026-05-05 11:44:14.203	2026-05-05 10:45:44.295641
f41bbba7-6a5e-49f1-be54-d5f3a4a4f562	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$X8YDyLqAyUhapLggxlvQ9uLsW6FAmho/NL7JauYbDPc4femrr/3.C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 16:45:50.478375	2026-05-05 17:58:44.425	\N
44adbee8-eb89-4eb4-a226-3876976e283d	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$Ae3Krjy.tA0g9cfwDv/TseEkL2Pc9N0gRotV.fReaNBwUo7Nclyk6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 23:19:29.50514	2026-05-05 00:34:37.116	\N
5f742356-4d06-475a-99a9-725395224cfe	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$DjPtOA.4aik69HOLt5xwP.tdjZdw6aEYVxGy.dNo97XCBZhiOBqQG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 11:11:50.874468	2026-05-05 12:14:26.844	2026-05-05 11:14:42.25048
b37a060e-f022-4f88-bc99-5b29f2501df4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Xomf3jR6YeMHUZzFaSPyhegVvuanB80gx79xpJztxaKDAs2yIfV8O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 23:27:41.832159	2026-05-05 00:35:45.98	2026-05-04 23:36:02.072915
32639dea-d5f0-46f9-b75b-2a4338d4346f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$D3g226dhEcNuqUHO47fYd.LPgpzmaqLsLLbPb2OYfD8c7ZbbRzmRW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 00:10:46.071342	2026-05-05 01:10:45.688	\N
2651f4bf-a24d-4471-90b0-e1625e678aab	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$A3faFLoy2u7jze.WIu5.puN09ungWNaNVpWs6S.1izjANe2JC.6zG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 16:26:02.134507	2026-05-05 17:59:37.196	\N
dd84e4dc-ece5-40d7-b9d3-3cc202cc75bb	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$JiNO8XZvDCKe8xHyWlCBmu9f8H0H97lAx.JFgJ9rvK9taVle6ABx6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:18:20.72991	2026-05-07 09:18:20.279	\N
845ad5fc-4f4c-45d4-90b3-a35b3f06822f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$WXcUbxq6mk/78kJ9NZb7.eGAGj4g/Y67EqQ9rWle4HaGp3ezdLiIq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:18:24.332351	2026-05-07 09:18:23.888	\N
e9782ec8-d057-4ac3-b93a-cb5c64e559f3	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ADDIZavrsT9sgj/Bqfh8o.OI4w6mftOdGOe1GGKTPOgztA7Ce354K	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:18:27.41604	2026-05-07 09:18:26.968	\N
21d7a849-a43e-4a55-a144-60aff5d200df	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$FEt9UdQlbT7rgSsetTFRzeQxKec78Dyoq/sYm3emvBiw48bv3XaOi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 11:47:47.241092	2026-05-07 16:54:41.954	\N
804d32fd-4cce-45c9-8364-cfdb972ed20d	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$z2hnbju0rILL7xnapUAhdeiem.zIp/Z313rxPVGVVtNLrphC8u/Ga	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 13:22:00.297822	2026-05-05 14:21:59.828	\N
f1450113-1805-4e65-a79c-6b88a1e67430	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$68L9Y9wwZMwJ0ivfdNokA.5fnovfYzjefbbvBEuqHMddKsDqqSH6u	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:48:41.480168	2026-05-07 09:48:41.019	\N
47dbd474-c6a8-4a03-9dc3-741400620a99	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$NlMlYqdZQZG2QyQ6g/YtYOjypNHZpgzOGnj3XlTs/E4ju3M5VBkH.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:48:28.80495	2026-05-07 10:09:17.127	\N
6bdcb884-6737-404b-aa6d-85fd1bbf6a24	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$o2F0gsbW9lGeXH1kBBdS0eAcMmmZ4soQJRGt8oAjpkzS4wn85ecJW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 11:47:40.946879	2026-05-07 16:40:19.218	\N
c7ba94a6-8a5a-49e3-9cda-4ac644736c2d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$buFekqcPxgTiis1DxkjmY.GOwvkCptN28pygm61ryC/cNdvX3GS5W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 09:45:04.358675	2026-05-07 11:13:47.423	\N
827b438d-666e-4a4c-a7ed-11aeb8bf83ff	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$syb0JXSkxCATymkMNMrIl.Mjo4053EJW8kxi.oxKPsVBFfoByqy6C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:48:35.964093	2026-05-07 11:14:09.566	\N
3af9d2f1-f56a-48fc-a7c8-cee1b80629d5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$FUVwWdx1VojlXSnOUIem6e.RBgCy5.5HwnQuIHARJwRm6lp6aYcmq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 10:56:36.178295	2026-05-10 13:23:27.212	\N
c345af35-2380-463c-8f60-7683b4e11818	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$AGvrrbtH8zVI2ivWQot/Hub9PVq8RlxxoqXddHJbs0iXnbHKKquvu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 11:18:12.776991	2026-05-08 12:27:07.991	\N
cbe45231-0372-4650-8716-a0c9395b8954	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$toU7STJDbMTQo60hrOZiKep4sDu0O5FuqybnHQgB45TvMpzLmXAuS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 11:47:58.200795	2026-05-07 13:38:39.318	\N
c313c446-b892-42ef-9850-daca1ea73ee9	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Ugag2eovIihSIw4gV1CUoeKUqKe0AsWjCYnqMycVyksA/HTnfmJuG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 11:27:41.170673	2026-05-08 12:27:40.786	2026-05-08 11:29:05.195108
8248773d-0363-4e04-905b-1a0d18d8b71e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$hpFXpqTBgb2fv1MkhkIYjOFR.5A0iFtV8of20AiylMZ/JjOHexG96	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 13:39:14.196632	2026-05-07 16:40:22.818	\N
e51b919c-3ee0-48fd-a323-54b1e3bfa6ba	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$ByG3RYrNZjKVpFXBU9eyG.yLQxbyVfWk6Y28vGavl5XcJCoNQlbny	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 11:27:47.772761	2026-05-08 12:27:47.391	2026-05-08 11:29:06.899695
56376fb5-05fa-4357-a38d-6320df049679	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$2ZCGc09ek64lWB0Yejbb4uyaoSe6C7tZMzWEQZN1VYiwEQbx0HoNC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 11:24:22.224017	2026-05-10 12:24:21.935	\N
86ca394b-475a-4f53-898d-53874715fbd2	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$JgEPbD3l5ZNgLwsMcaBmKeiBgI/PTCrcSjP2b6pT95o9CcVXYtC2m	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 23:51:31.825246	2026-05-10 00:51:31.443	\N
ac43dec5-251a-4606-9c6b-6d3da4dc3b62	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$93Wf8HFHIxJn8EFvV0a4D.eqJ.1PS1VFXLMRnAtNpXX.4iF1rUxrm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 22:52:26.893941	2026-05-10 00:57:42.118	\N
9f672802-2118-4876-b11f-c02b5945ff7e	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$sa8NtSC.Mccg.NfHFlbApeCjjho8xoTdwwo5kezOLhKLAM.Nonpdq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 18:48:57.427447	2026-05-08 20:27:20.981	\N
9faacd1f-dfe0-4846-ab7b-b8f23a890e03	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$y4eEXCXwuOTcuRTOYKEUq.esqUL8QcA29CTs9ecRG4OsTz0VMfG5.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 18:29:17.537039	2026-05-07 22:43:40.471	\N
e58e13bc-7e7f-41dc-ac94-6ae3d8a3fe22	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$IOCHwAmh0bpSpsq767PKL.PJnzaCMOzHjyg6yK6pEo4ihaa1.FHou	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 08:26:10.949684	2026-05-08 09:28:21.077	\N
e1e8d98d-6717-4905-a87f-dc87d59a094b	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$/LaTiQSX/Uxia7TKthwwD.xoOQvZo/CNR7ojkAUGCfGl022TlFiym	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 09:11:51.625414	2026-05-09 10:11:51.149	\N
37cb5d6c-9330-4ed8-b88d-7def98937165	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$BzzntXvni6ZbmchnthDfLeWgpYKX5Yp/ZRyLGcq.E1sJHyKbucTsa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 08:29:36.515181	2026-05-08 10:49:10.496	\N
721570ab-c616-494d-aa1c-5ecdb2fe2122	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$ycHy9NGRzeFTvIN3qaAX1eElZo1hKvtUY1KCQxGuObAKd3poR7URS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 11:32:48.440041	2026-05-10 12:32:48.065	\N
e919c792-a9d7-43a4-a931-aae55f321dc2	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$eL230dccPl1frNzIIkM37.y6N.J/zmDMujvmbmmAi0KR5REU8mf.a	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 09:11:42.265289	2026-05-09 10:17:14.44	\N
13715f1d-c9db-458b-bda1-8d70bc2b4d26	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$tW5JadMnuxJMcDudpqUZ9OF.SDFTqNW/CuI6VdcHLfhMQ7fOz3mgK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 12:55:47.19596	2026-05-10 13:55:46.822	2026-05-10 12:56:11.146297
24f395d2-1ce7-493b-83cf-d5b8c927671b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$msEvmopeC0.mcC8/DbrAzubd64ycOXogv/itT86kRKaEfVc8PfayS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 09:14:10.018287	2026-05-09 10:19:06.104	2026-05-09 09:19:21.654906
bf579ba1-f8ce-41cc-8aa4-e77930891e33	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$xKH68Hg8EIJGaVCKp.JF5OYUNIMC3bBRIiK0vI17HvZCtieeeBGS.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 18:37:02.132262	2026-05-09 19:37:01.737	\N
7226bcc8-25db-4f69-b038-93889b404cf2	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$rNOM2lzSjIoWU/RJ63w5IOjiumCkmsbwP7xQr/Kd7hYWgWu6Ai1na	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 09:10:01.903549	2026-05-10 10:51:57.336	2026-05-10 09:52:06.149586
d1155661-37aa-4b92-8f9c-fa6497dbae6e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Ny9634ovTHupuXh9zeG.fOm3uAjEEuFhyy0noFceKml6WPud4Q9Qu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 17:50:36.763843	2026-05-10 18:50:36.377	2026-05-10 17:50:38.968614
49dd1286-a566-4436-9bff-1725e34905ba	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$2cc997bsh8WFI/SFA6nYseTDMiCdIgkZyAm7oIqEI4ua3gLjaJYV2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 09:52:17.328906	2026-05-10 11:48:49.397	2026-05-10 10:50:34.488175
0dcb4fcb-e83e-4228-9f88-9432e0075c97	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$p5u4R.fNulsUZ59/oQ0WJ.4Ep.RJNadZdbr1mc6u0PLqnObzCn/Iu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 17:50:45.767843	2026-05-10 18:50:45.381	2026-05-10 17:50:48.492011
3a1e9fe5-f609-4102-9deb-de8e6ae996a1	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$sJVsMGX/UMhF9MZzARB3I.oAR5sHibtprmMx58g3d.kmxCA.b3axC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 12:23:05.012551	2026-05-10 13:23:04.629	\N
b10ae60a-4abf-4e75-af2b-225ddbec2062	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Iwd5pPoQTPkFY8DvyV2P0eOzGV.ZG1yuVEI9coNsd.NxtqNt6RAfa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 17:59:09.467644	2026-05-10 20:21:26.491	\N
362d3fa7-a28d-412d-8f4f-83211f7a5dea	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$NbaDLclpqHdNH4FxdasWo./8Ao20iZgz/j7D.XzcZ5E3oWZZwKBQG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 23:36:49.792818	2026-05-11 00:57:26.169	\N
05fc8602-5afe-4c3d-acf0-b181dcc2ee6f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$IF5ngn/l4oVzDLKZuczY9OqV8K9rkljJqy2yrw342yhBEMT2o91pC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-11 00:21:06.93273	2026-05-11 02:27:43.732	\N
b1046ff7-8a90-4c0a-ac47-9ea0693edf49	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$vdekGZoCJyLhy6qAS/0gOeB1vWCS9oAg8B3fDSQ8fBoe7RJ2CRZwW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-11 11:21:39.161235	2026-05-11 12:26:52.037	2026-05-11 11:27:10.190979
839bad1b-633d-47e0-b7f9-68b1e31c1812	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$dE8F5jMLtAEORHFkFJpOFeP2JSiGZ1RX28eR4IsuAlceD4DeOggRO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-11 11:23:39.805323	2026-05-11 12:26:17.683	2026-05-11 11:26:47.451221
69f2c06d-dd3a-43ff-b4a7-c32eb09ed5bf	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$wjko2xN7W3Pox.3KH7h/LOVr9nGerTYmFZI7/qRjbXqek3CXfLzcu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 22:51:05.608038	2026-05-13 01:03:13.379	\N
c3b673b7-3785-4c45-8bdf-a2f8e892460d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$H0V36dbB3EY0vovY4yG.huLdA/Q1gAcanc/kDcXE3kEDtp8YGrDIa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 22:51:14.218911	2026-05-13 01:03:14.327	\N
cea3903c-b7b8-4204-b9da-f2a7019bf302	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$4KytYYrGXueHdZqdvOnAEuYGgUdxmdXBKXq24BbvyYIRVlkL6qd6i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 16:31:33.875436	2026-05-12 18:48:28.507	\N
f52ad36f-f257-4174-949b-91f3a601d736	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$sB.Aw35Y9cZpisRe.IpffecjKIjlNkaJy.YRTUPmfv42TP/J8OXaG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 16:31:18.37053	2026-05-12 18:49:05.153	\N
5b75fd6d-7cfb-42ce-a051-f5a20454e20e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$zUIvh06aH0hfkkcXpalcHO9Ha1oWwsxSRV7/JYfTQOhWSymkqkPK2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 19:33:26.592281	2026-05-12 21:42:38.961	\N
2c9b75ba-001b-4242-bfbb-d0a5e728522b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$a2cnMcogD1uLyD3oDX0OXOZSo/AFh8EMQnbK8WfFXVtKyYVExFbcy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 19:33:16.437641	2026-05-12 21:45:18.401	\N
06276927-9b78-4b52-a9b6-c0568e7d9a5f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$I9xjY/NcFhUv5WH2G0Gwsu8zv/E.4HZftAKr2PJYlWGHnqbC5Z/MC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 07:51:16.46843	2026-05-13 10:14:11.37	\N
390ab7cd-749d-42c5-8e27-0b3277e6aab2	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$fMaM9E4/Y0Yb0Yveds7cjOPegj7Bhf8e5Aw1eEBtMdjhMt7m7UA4a	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 08:22:04.937263	2026-05-13 09:22:04.551	2026-05-13 08:22:18.857999
1853868a-cde0-4a76-ad5a-1d9cd5eb9f11	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$OrbMe.PE2qKg1e7Pz504fO8aFez6RGuEq2iwQtA49nEQ89xRrWrTa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 07:51:10.712553	2026-05-13 10:19:30.609	2026-05-13 09:20:42.265871
092664cb-4d92-470d-887b-e24853b01f6d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$t5maSIGyOFOKiOrED4msUufkC6BAmKQXUSrs4ADiaVETCHMgW8WQu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 00:10:44.491071	2026-05-22 01:12:57.502	\N
8540a241-5bcd-45f5-bdfc-c361ffaa4c52	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$DLgzsJj.XneoQYJAD6WLhulRgE0BlQvGOLJ6q3QEaaWFc7YcgrNyy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-18 07:58:20.562582	2026-05-18 09:55:14.521	\N
4cf466c2-d0d1-4911-9fc5-2c6e3a941145	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$WQsG4lYvSLu8M0d6SKE84OGVXXV6O5eYRdrgSy443NDNYKYl5KFt.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 11:22:12.675654	2026-05-13 12:27:19.135	2026-05-13 11:27:39.367492
10b1bd4c-1fe4-4132-a5f7-031ca51bd85a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$OmLzK.7Y1mb7Kylbv3ld5exccUBzteX.eH7q5AFaciC4Wa5z23kBq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 11:05:39.528391	2026-05-13 12:30:31.15	\N
76c49f4e-118f-4bda-923d-609494e17155	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ekSaxx/ePpu9Sc3C7Ldc1OsxNVCFo6zpFqfdAEUb.QIMHxoP31Ysq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 11:30:58.781502	2026-05-13 12:30:58.313	2026-05-13 11:32:02.824367
ae22d5de-42e8-4eb3-8d9d-a801942cb48f	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$PkpnTS5MQNFhhaci31zf9O9pYkTrX88NYP7Yrud25lVLRw0qKOIA6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-18 10:04:57.186318	2026-05-18 11:08:10.476	\N
ed524978-0e99-4089-845e-975a3dd17240	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$Ma5MYjx8N44ppMdoqBThdehxHFLUK2dT.Yst/2dNIixIfD.XckkNW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 11:15:56.534219	2026-05-13 12:38:17.623	\N
69776f2a-b82e-42d7-8988-7e661b7105c4	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$RTTyUnWRmg.Of8So9iKVieG3jG6N2s9i4ChBA2LbInGz03n4l0zxa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-19 10:39:15.293398	2026-05-19 11:39:14.918	2026-05-19 10:39:51.298906
5dcdbd85-f284-430f-9921-33191aa0a6b5	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$x.p34Jh3tE5BUn1rsKkJVeY39HoQ4k1klmaIGiqfuT7SIHGhpyiky	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-17 23:23:40.092057	2026-05-18 00:34:03.466	\N
1f2b456a-7fca-4d45-8e26-8bd97be0c761	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$dB6EshX6oTAhfy5SevWYyuRwDGKMjH.M4k7eBtpELnHo8QImOe4Fe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-17 23:23:02.16093	2026-05-18 01:03:51.792	\N
e843e3a5-df91-402a-8999-a9022d2938a5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$zE9jncEBO4DhCd4FhrtMTOlj8BR4Qa0oa/BEMGDbl2LGm8fIxNjcm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-17 23:23:19.741134	2026-05-18 01:03:55.885	\N
3249808c-65ca-445b-bc78-dd461d7d4045	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$LQY/YBbsp7goLVMjmhnLHuFXFWqp9sf0zlBxl.9avLUvs7DddDBeK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-18 00:36:48.427017	2026-05-18 01:36:47.951	\N
3b1e73a8-852d-4e8d-8215-669e2a9cb47c	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$S0blFfw8oKc9dGRAtR0SyOvOzjCqqkHYHzxzG/1fbs9Sph9AFSEke	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-19 10:53:35.370999	2026-05-19 11:53:34.992	2026-05-19 10:55:24.26428
2b230911-18a4-4602-904a-804c9ff46ed8	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$MR7UBy5pf8olnkVuA3ra9.RPI1v8TtltgR8hqXA/2sb4uZVM91SSq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-21 16:08:18.259295	2026-05-21 17:08:17.799	\N
e24ddf87-5a4e-44c1-a8cf-a4ed874fff45	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$rsH3kOx4Q1b0CX51CPm0aebtJfd5l3y5oel1qM8CPvdlvHUKaIEHS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 05:15:42.581523	2026-05-22 06:15:42.194	\N
abca09b1-0855-47cb-8f2b-1110e1a62f31	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$djtFwEzgIPdVrXLwAv3oE.9kVtRLpLbA0xSKzuHRnZmJcV3Sa/yP6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-18 08:33:10.511161	2026-05-18 09:45:09.301	\N
40b4a1c8-df83-4de1-8d59-bdc3bf28cffb	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$.WwTygG3gF9wUzXeQHOYqewBMOYASWI8gU4g05kv8EzARmNLvNidS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-21 17:15:11.441674	2026-05-21 18:15:10.973	\N
19335ce8-8500-4490-af49-35dfda20c0c1	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$Nz6DKmXNCypAS0GFpYMXh.bjPEYua/d6Zn/kv.aW1qAWILsmEFQ4W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-21 20:41:36.615092	2026-05-21 21:41:36.221	\N
9ed7a753-f255-451a-9888-808a0687c626	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$fVbu7mOx3G7Dt9.GLbWCfuUKFANbZ7.7lfMuSnyvojfFGEbA6ZfN.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-21 20:41:43.421714	2026-05-21 21:41:43.03	\N
69fb21e7-25d0-477e-9fd7-1679131ed1f0	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$7GCu6PDrIWooZb2HHOFgS.T1IcuhCnD0oJadfQKDdYvlUEIITtXve	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 11:30:05.832583	2026-05-22 12:34:22.392	\N
1331b21d-20cf-4b14-a132-9227a95dfdb6	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$y08Hd2E/YNBwTKE5.fv66erKYvQBY9xWXrTc8cFkrThdDfo36k/2S	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-21 20:41:28.175863	2026-05-21 21:52:46.085	\N
f02d38d7-1979-4b34-b4f4-86eb57794a00	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$QJxWoS8LmY0OyOnhSwlny.rdifWmG3Dq5hmGP2mM93Y5z7T3/hzdW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 15:52:49.378759	2026-05-22 17:50:08.507	2026-05-22 16:50:14.055276
4a7d0717-dc2a-47eb-812b-d6fbae202fe3	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$aldUNQoOWZMcu8k9Bmy5OOyN84q0j.2zBlVqDAXAguJEXPW5VWsDO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 13:35:27.933426	2026-05-22 15:22:47.746	\N
1dcaaa7d-f9de-43fe-8afe-2dd9e9935f43	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$VcN9AYc0sPCn9c2Rxt7J9O3Xgl27VplHI1bSqoqJcawM3D8HlQwv2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 15:49:07.754313	2026-05-22 17:58:57.937	\N
c46224a9-3305-423d-92d1-c72c8e2f94f6	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$CrYrYGZJl52yNGXdSis6hu3WBjScnh5DwJSmipmE23nSLaWC4kPt.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 15:53:08.91145	2026-05-22 17:50:09.222	2026-05-22 16:50:11.797709
16a8f128-1dd7-4909-bd85-f7551370b5d9	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$PaLgnK5Vsdfl8WO4ccOMf.oy7eHiGpNM4m2E86efry.wdTLaPBRZu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-23 11:26:31.782924	2026-05-23 13:12:39.148	\N
69cd7874-04fc-4e46-93e8-6372f2f926a4	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$CsPNZsfwoArQMYQ3GdIlku5OTwOAwRNb6gidh53BnDYHHtadnWX2C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-22 16:59:21.203211	2026-05-22 17:59:20.802	\N
e42b9753-3184-4d97-98af-24a70fde788e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$BCYFhOhizdFmcBxdKCE12.xm/ANzrcUA6F4QVkVhg0xD5H.Ce43le	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-24 20:09:27.808965	2026-05-24 21:09:27.429	\N
44c106d5-e33c-4b43-b1e9-e8f190a9740c	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$oMi29OaAO07BibxTm7ena.KtTjCjRxADTXbiq1D.XPVUyyaL1WNwq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-25 08:04:46.00907	2026-05-25 09:06:59.665	\N
448a1009-6220-47cc-95d6-9b8555cebf77	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$WJF8kd03eC670ymSadn.n.FUZuv1NXVfUCgTB4R/dy658bQ3fyO6W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-25 10:04:07.919349	2026-05-25 11:30:13.019	\N
bfd73849-f331-4e77-a7a1-22463d73eade	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$cQ3ImMlqqb6MmD2ed55Pq.IVdtBTLfkkLZiB1WjovxJ3.e3iF/vSK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-25 10:05:02.715648	2026-05-25 12:09:35.801	\N
b35c6249-7a7d-4ef3-b194-36265314c722	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$TCGIMuhs0HCYPeuatk.L/e5h2uDqHskfONZGUfqH340malyd4bUHi	Mozilla/5.0 (iPad; CPU OS 14_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.0 Mobile/15E148 Safari/604.1	::1	2026-05-26 19:09:02.516669	2026-05-26 20:27:33.357	2026-05-26 19:28:40.005975
afa7cfe4-9492-4371-a80c-957071ede7b7	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$HYvOSyhSWt1c0bTs3AF/LeQ7i./jWM6Xi2FzHfFWSPLLeUz7SZ58W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-28 11:36:03.668307	2026-05-28 12:36:03.293	\N
d37dca79-849d-4e24-945e-529ac1171751	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$f1C6nDmcdkHbLjHzVQBM.O94MMPHEO9XU1/zR6m8zoyxL/KRxbBua	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-25 15:04:19.28413	2026-05-25 17:46:57.431	\N
7db6a0ad-1572-455e-ae5e-d46d6f846169	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$7V.fR0BiQE7SVTbmoIYXtOzlXBa8oG8BVAXizfE0183H2wFvW7LZi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-25 16:22:47.331417	2026-05-25 17:53:01.891	\N
aa238f62-c370-42f7-9471-cd43f0d9741f	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$LfD0qzIKu4pTnFn9JtGct.05.XZ8k7ldTL8HxG7OWOIdRS0RAq5Du	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-25 16:53:24.275296	2026-05-25 17:53:23.898	\N
8430d2dc-2e9c-41ec-bf21-9c01e1c197e9	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$k8./NniyqJ4QPVp4B2y7J..f68qrGS1JS.uZtFDSa5F.qxW4MqU7i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-28 11:12:06.167496	2026-05-28 13:22:08.562	2026-05-28 12:23:27.511362
7322deba-0fee-4b0b-961c-bc17dcb5df2c	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$sNJ7/r5/9GxEc5Ta23CcUeyTkhszCmI1U7XfI3k9Dw4bAAruIy.gK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-28 11:11:48.166498	2026-05-28 13:22:08.765	2026-05-28 12:23:29.039994
56e180b2-28fa-4063-937f-20cf354d5a6d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$j4iu.bnk/SVuqeSg3sEw9eT56iCsmczO.2l6XC7O/TYDPLcfQpjw6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-25 17:00:22.292423	2026-05-25 18:12:35.598	2026-05-25 17:13:34.75997
14cc2285-ee3c-4fca-8c85-6c9039f41662	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$XplHY3EbeekMNY07JUBr/efIQjPL9ndbyOGyPXb1A7bg1GlQJcXf.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-26 19:02:47.563125	2026-05-26 20:02:47.098	2026-05-26 19:03:09.259407
d2299478-f083-4bfd-be1a-6281ed1a6c99	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$vgDPRLEIUA4pMkQTYvZMQ.o2cbNcGwgof96nIBtL5GRL38ow34Yk6	Mozilla/5.0 (Linux; Android 16; Xiaomi 12) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.6778.260 Mobile Safari/537.36	::1	2026-05-26 19:05:19.74117	2026-05-26 20:05:19.272	2026-05-26 19:06:53.539743
f54366d2-45e4-43ab-b00b-cc095fc52a25	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ogvszMOYgByTXllOki8yUeqv2x2tl26.fGTAbYYJojovxEAH/Q/ha	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-28 16:52:08.387803	2026-05-28 18:29:09.373	\N
ad17edee-0ac6-40f5-9a4c-be33803755be	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$MvL1sm5lqEEyJPgnQQZgM.rOhvAtS5CS2Dg/cmhTSRdeurPQY1DZe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-28 17:29:52.13568	2026-05-28 18:29:51.76	\N
e5c366a5-c2d0-4c3e-958e-cb2bc19a6b4a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$BJQ/Hc8dEpjs2toVQGmaLOdMxpk0sZnAaHd9wE9kCr/A0Ki.t.dhK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-27 19:53:30.071549	2026-05-27 21:41:47.699	\N
c5243ee0-4a7a-42da-996b-bdf1a8b78373	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$HrA5Y3jISlO4zL9z/SM66emct410uWQH9FmUuXUegoaPp9/s.dq.C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-27 19:53:46.015705	2026-05-27 21:42:00.319	\N
4ddb87b1-73d1-4e99-98a5-5d7edaaa02d0	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$NUK/u39RHVuxMPVMg4mnreAJEzN/Zuwz2CgqY72tYJlU4ttjG5yfe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-27 19:53:51.318598	2026-05-27 21:43:39.675	\N
56fb8c67-dd14-480c-934d-547d0002c369	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$7B2QU0joWONSnxxfjyC/xOIP1ByhFLVtgiJWw7GcfuRjmXYh8V57C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-28 19:39:30.811192	2026-05-28 20:39:30.435	\N
692fd864-3ae9-4602-9ff6-2c65579c481d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$cUkEkcVYkKLnowowz6PnCeWsTelvZEpRVniC/dRI96vAqRk735Ax6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-28 19:39:53.207034	2026-05-28 20:39:52.833	\N
6aad1a39-20f3-4727-99cf-03a22e50806a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$YfSmid9b9QiaL00zWuM0P.026TMnUSPAA1vwshCrV0KIFk7Z3Su8.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-29 05:32:17.285517	2026-05-29 06:32:16.911	\N
1345ab2d-73f5-4875-b12b-773c507c775b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$tLwtoJRjVIygGbJAlUQP/.CZL/DAQ8Ic2s5BMLUhW/44AF.V6vs.G	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-29 09:36:22.593626	2026-05-29 11:18:46.832	\N
be3f48f8-1bfb-4e37-b0c9-8bcc4f400a7f	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$GZ.Be/hrty8TTzPLdWMK3OHSkQ59HElrio.KXGGh1HVPNmymbgXXG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-29 11:28:14.336263	2026-05-29 12:28:13.87	\N
84bb928e-a6ed-4af8-abc1-1b49fc6d2ccd	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$xGjyKeiLiARgKHK1IdmhqOXD1IljR1BVUw5NwERn4gOvF7PX1yQJ2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 17:48:54.586425	2026-05-30 19:01:28.676	\N
55440219-0593-4adf-8b02-c9ab13ea69de	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$F1h0rhXbBAro2T3SJrNdU.Us2EO89c6bfjOJQxbsMsjZezLIcCWp2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-06-01 12:09:34.330814	2026-06-01 13:12:37.325	\N
d234bd4d-b46f-4723-9584-b3b7fd176c34	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$FhFuyympewmZzT5F36vExeXXVSTIqLAEV7ujHUYWefWhPjqN8L7S.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 18:42:55.746766	2026-05-30 20:05:55.073	2026-05-30 19:05:59.35152
ca7fee25-3f77-45b0-be9f-785826b614e0	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$1lLl2glEUqjNFPttwUSwAe/4vdDig/VW4tuMkut/yolQewRMnGY4u	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-29 13:37:24.326726	2026-05-29 16:37:02.522	\N
b98be430-5320-4a08-9edd-8586803d7a63	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Qah7lAuM/ieFLYNgjt43zuL5RlfUh6wmDPi5hcMD85xBflOg1JRZS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-29 15:37:37.142011	2026-05-29 16:37:36.763	\N
61336ec5-859e-462a-916e-0c3c33f77011	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$wd/lPMZ7ydZR2e0hXCbx0eslP.Gltkyxl6cHOt0PoWrKPUFYMQR2G	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-29 15:37:37.631591	2026-05-29 16:37:37.247	\N
f2535e3f-e0d4-467a-b5b7-1de01fd2b76b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$8PeYpvvhe4LYh/f68vK4Fu.i22Vpfd/iPtQBLALzMC//w4WYEYqxy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 08:15:49.39231	2026-05-30 09:15:49.014	\N
69332277-2c69-4dee-83ac-c86b58a622b7	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$UvBrmNdE/kxjsbEDmZBypOUNmPvhimmFQZG3tE7CZ0F2Fcq7iCnCq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-06-01 12:17:44.386073	2026-06-01 13:17:44.009	\N
2658003e-f230-4f6a-a838-9d8418e9c7ec	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$yF3BSnI18OTrhB7ol2/OReKm9Sh6rbZat/lRB8yApf9y3cltNbkfK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 09:31:32.374148	2026-05-30 13:00:01.796	\N
6e88b1d5-b275-432b-82d1-198540047063	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Xg0UjcUruD5z1NhoHZ3Buerl4u1bur.BMJ5xIT94dX/mqDzyqSDha	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 10:22:49.261189	2026-05-30 13:00:10.097	\N
8d9d16a7-b66d-4e3d-9174-c73f42bd7da8	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$5GemBlUIco827PpsW/Y/FOx5I3reGcnnIHHMZssxZCKtJjtEyyq0G	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 11:25:43.053633	2026-05-30 13:00:41.721	\N
311e9de8-9a80-4d2c-9702-5bae1a3b532c	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$1Ybypr4iI3oCjJFMLMaHBOEaNbEznEb8hsyTKwH5F/FB5wElO/lse	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 14:23:40.819801	2026-05-30 20:06:02.205	2026-05-30 19:07:06.286595
773a00b2-0a10-4ced-bd4a-47c300e1f222	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ygmFi1/.t1scO90bFDWM7OEMaRMszZCNiSj5fbIuhKJbPSSsWJAIW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 14:38:47.005303	2026-05-30 20:06:13.093	2026-05-30 19:07:08.230509
cfaa146d-1664-4b96-88d7-5fcc8fa07115	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$GKHnDkkerPcRUtF8tSsUhOAHYJ8BAgjOO90Yc6YtnU982q.fQqoES	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 11:24:57.558028	2026-05-30 12:24:57.184	2026-05-30 11:25:28.213993
15aae26d-3a1a-4bae-892c-a2174ae60356	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$39MwrRSmsklFS.Lv2Kb70eBYFRAkOXtmiQ.rbX/6oHQHBwZup75bi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-30 14:08:58.107405	2026-05-30 20:06:02.875	2026-05-30 19:07:11.114347
c0ca7d42-5a0c-4313-9bd4-e78524909803	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$47ez9bOlIMoRtc5JNLEBY.aznfN9lLh0Ck5SK.SeH2jil3pv1T9D2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-31 01:07:07.659689	2026-05-31 02:07:07.276	\N
b469120d-4973-45fd-89f5-fec2a86b22a5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$eD/uM9Kv/Vw/gE0E4XE2Ye65XV1S2ymnR8gX/HZPsuFzLvTE4PQEm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-12 07:50:09.770354	2026-06-12 09:04:24.992	\N
e97822c8-8dd2-475c-ba65-ddb4338d55bb	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$wYm0OIkgYRnXxxCAhC.S9e5ozCS1hDa9c/BUjwsxvEKf9ThUwWO9G	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-31 01:24:15.026455	2026-05-31 02:24:14.649	\N
bc207b6b-8282-4c64-86f3-2224e3b7943f	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$bKK/SW/Kd83CDcbhrPJWcuhZPiO1VukBu3OEpx18si5jEYsFgRLZK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-31 01:24:23.426503	2026-05-31 02:24:23.053	\N
7743b9e0-1bb7-430f-9592-c9d51f7220f2	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$rkqpR1aEb7C9b/W8v/Fha.ujMomaSECKdug8ObSsk6khILxwkgMVm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-13 08:11:56.061204	2026-06-13 10:14:13.501	\N
af665911-5cef-40ee-98ce-54aac3445544	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$aJWB8a9ANQXXcW5vNJJpj.YnPL88bxyNN7vUrbTJo5L14QAtxYywm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-06-01 12:16:55.499846	2026-06-01 15:21:33.336	\N
4a867c07-0af7-4b86-bfb6-2583aaf78d2a	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$JTOA6I5SkNAtnyTLrKinG.VTQgT5nIE9/TvGFLDlKAPTPNqJG/8la	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-12 08:06:17.771186	2026-06-12 10:01:36.173	\N
9db2fffa-9508-4db4-9957-9c4295a1d903	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$GxVVeO1nE3/VY3dD1UGUM.GMVW0xdg7vVv9DyF8QjCZWXv9XmoDKu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-12 23:56:16.202533	2026-06-13 00:56:15.823	\N
835678c9-9221-475d-b9be-8e0a30b3c925	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$y/nHTb5DD/s/OhpL/pF/lOXgc6I459OYrotR8qSneWPLRIkZnDPFK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-12 08:48:13.894986	2026-06-12 09:48:13.516	\N
f686b927-d5b6-45c3-91f4-15f1747dc2a5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$p0cRFI6yNMUjv6wZjsVr/OAD7AlT5Lvy98CiAIVqqGDOHKqJ.PS/W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-13 16:15:00.113247	2026-06-13 17:55:03.3	\N
32446959-f7ed-42c0-b23c-047dc01ac8ba	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$19m3XEEfnIVgrgVtyvuQYOtkjLZqhcwxVK7p/mo6p6g0eLg1PVjza	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-13 20:22:36.445118	2026-06-13 22:47:32.734	\N
b8b83a35-9211-4948-b28e-f676bb6293ef	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Jk3Uy0OIEBvCuBcM4bsAbOmhBTVG7UP9UjUZtUtYV2vcTmSHcBbFK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 18:32:33.583193	2026-06-14 19:34:42.48	\N
0e5a6a51-3201-4863-86e3-bd54a228c0e2	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$7MuHswe81YBiL0TeFJjIYuhb.OBVeP1kZzo2FMZ0qdX2gVhM2.k8O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 00:27:07.746444	2026-06-14 01:32:46.01	\N
fd13b11c-462c-4654-ad84-598a3f9709ce	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$tCwGpnow.hnFXGvsqQgR9.mfXEcheQPHa658RVIu2L3kh8h0ypk3W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 00:28:52.217123	2026-06-14 01:34:12.545	\N
109f5246-4fe8-4b73-b57a-3b855e9709f2	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$eHlCl062d4jllUTWWjQFbOIos/gpGSrkmBbv1ufQzDOhIuDynUZdW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 08:38:05.162195	2026-06-14 09:38:04.785	2026-06-14 08:38:54.902553
e3e64455-95b2-4753-8713-d62a4912e237	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$9AH6u2OCjYkP8Y99hJj9Desk/IklwYNaQbxIEoO3/Y9lFjOxEuiBG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 10:06:14.965883	2026-06-14 11:40:14.457	\N
553f18b4-5c6d-482c-8d24-ba7f423ba7c5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$sjqQTsvjfVcjy4bl8bJb7O4pnQjGjoVCsg/.Elp7wegyixw6HPftu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 09:59:40.689592	2026-06-14 11:40:15.442	\N
410cb474-28fb-4050-80f1-60cf17935347	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$/c5tYSYEvjLsgjOncl4z7evK0Q3akd0xdseGg6wDjRmkoSppDidFK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-16 21:02:59.194009	2026-06-16 22:02:58.817	2026-06-16 21:03:16.431764
519118ef-fd6a-41b0-bbd8-783b7042b79d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$MUgI.0ejlTF3395A5CiIKeuE5Nlv0dsund4TtrzjJYP9jS8eIxg1i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 20:13:13.741873	2026-06-14 21:28:01.654	2026-06-14 20:28:59.563272
7b4aa3c6-5ae1-4572-8661-f911743e6c74	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$sREVIHM0N9Ym6ShSSJ4HHOPq4Cx4aaPJQk3LCR3332dvEi8lRKDoK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 20:29:12.586445	2026-06-14 21:29:12.213	2026-06-14 20:29:15.065277
e46312d1-a8ae-40b4-b405-056b7766c22c	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Xn1BzIjU11NR6TPiQ9zvsuJjyIa7FTsoJjp96ddC9sS0NcScSgKCK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 17:48:07.621043	2026-06-14 18:48:07.229	2026-06-14 17:49:16.328832
41700701-ffd2-4c62-9918-dd360e47c408	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$gdm7SHKNVIylHeEilO2koemF8uv8XGSEcuaTQ56KufYDV/lFncpW.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-15 00:52:07.264913	2026-06-15 02:21:23.588	\N
feeccdf7-adf5-4bb4-8b9b-6ead96db1d2b	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$1e8VDExnbexLfwCv3Rou7.YxjzoXjlbE/O6aXWOpGpJHFjv3bn3eq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-15 00:52:29.18253	2026-06-15 02:21:43.389	\N
5f4a0c7f-3028-4a08-bc31-206adaacc8e7	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Ab6aAyx.R8ewMhSzTSBQcO1r/nw/EIp8ErFDiYx1U1.yIi.4JN/My	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 12:03:56.273143	2026-06-14 14:58:52.148	\N
4a4cda98-14f9-4505-b8bd-300068d496c0	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$R4Cjbc4Ihbzfs67gnERYOeJIUS8wFln9Iccf9TAzRzVcY.4eUSP82	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-15 17:58:02.029574	2026-06-15 19:02:35.161	\N
4f57df22-77fc-4c51-ade3-4df928fea1d5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$Brb4JvtZSc34blmEIfn/6O0gtTsJaQJIpPSjuJYd3DoHroLQCreB2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 18:24:41.387506	2026-06-14 19:24:41.011	2026-06-14 18:25:22.523193
d0045d27-36a5-4fc5-8f3b-fdd34b7eb3b8	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$zKUKlc1bnTTjZzP45c6u7Og.88V.XrGYl0mLWsFlRNciLgr.m0llO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 20:33:54.993153	2026-06-14 23:45:44.25	\N
bc64a3c4-8051-43f0-af7b-57a88fb76ffc	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$/1/4UodriDlSfZeE2Z16/OzVjYIotX5t.DvXmRIBXNZPNApO56dBK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 15:49:40.932512	2026-06-14 19:28:44.64	\N
762a78d7-2ada-47ad-bb04-bca878d53f00	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$fzGHKWTz2dYRTBSx5pcD9uMIjvC0uCYGe/3K20xBOWMDGDOESh5Qi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 15:49:33.397832	2026-06-14 19:29:15.559	\N
4592ad55-625f-496c-85f3-c78c283c116f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$lqQfNSs3T89clrtGhGsU2.6N15T8tq7fEKD.NYFVitLRimqpuSb3m	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 20:33:47.739563	2026-06-14 23:45:45.815	\N
8f53ff08-e8be-43d5-b700-72ba6a6ddf72	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$qavjdEqOSOuNsf2c.nqgiO2oxUE/z2jMMmO5rvK6FzZR85zWpMw2C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-16 13:32:10.64568	2026-06-16 14:32:10.261	\N
45d603d3-ee7c-47c7-9571-64b7450d6799	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$QU2pnonvRIfUfhNFSDFVpuQsn3t.cczMkY8Tc9opscc1nUg12NfDS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-14 20:33:27.399058	2026-06-14 23:45:47.149	\N
0f102e6a-f7cd-4c1d-a2f7-52ec8b9e0b97	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$M67K.BPnvct8iHZTUgPZKOhMjo9luzLySwPH/Dnxkp4ZOuQtsf7bO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-16 21:01:44.712077	2026-06-16 22:01:44.339	2026-06-16 21:03:24.729995
0795ea4a-19f1-4d80-ab2c-e395ca4872ed	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$aW5vcDso4/fXwXlTB5JmyuAkp4nIj9jeELN0ygslqpM9.9T95smQm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-16 13:35:09.814741	2026-06-16 15:10:02.252	\N
ad92fe0f-c863-491b-9f73-292c9075b649	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$zIFgFvItnqwQlJmONqdwzOPaDh3gncR5Ym8fDQsP9gl5/Aqo0SqQ6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-24 18:52:30.790254	2026-06-24 21:56:49.295	\N
5d306b5b-371b-48f3-bfbd-905b221633f2	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$/dFMGQj0FCu5WGTY9STNY.gmF59pViWpK4LitNDvH5t5Z.5X5vqLW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-16 21:01:05.639494	2026-06-16 22:14:10.547	\N
23177f88-e3d5-472c-9171-002dddb34d70	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$/moHys/rfLiLEIqTyTfR6.ckhcNREoO1f7FKmZ/Ae/Z2LERodrOaS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-25 12:41:17.2211	2026-06-25 13:46:06.743	\N
9a474e8d-b3b5-4e99-a6c8-3adea65c9d16	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$miTgwqX9mUYaJvSSMKB0tuEPijvRZhOmvXlvqk.WB0uc5BHGzqO5O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-25 12:40:58.604523	2026-06-25 13:40:58.132	\N
3830f6d3-32b3-45c2-92db-cbe649583ffe	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$C43gAM3to0f.FTl8kewai.QqtzLAVE/YyZK856b2F3vb2esFpL/T6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-25 18:39:46.855427	2026-06-25 19:39:46.479	\N
b501cfac-2c2d-4625-8b57-030a47a73b25	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$.zTtXt1eez0NcplnaXa2U.RKK8LUmK3T0kdDqzDUXbif0t0ERMvDm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-25 20:06:11.089274	2026-06-25 21:06:10.805	\N
737f3544-dd4b-4a9f-865c-7f0d231490af	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$u/t8QOVMBlyMQCSfwNgpUOiGQ15vbuIWKTHwmX6/JeXolcLU5lHG.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-25 20:06:28.826623	2026-06-25 21:06:28.545	\N
07fa42d6-9c44-4110-a2cb-afc8e0f79502	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$dsgmy99RVt0ESI08EKuWLOnJ2gVrK6dhY2L8PDp1muEFWiT.A1iye	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-25 23:13:42.788221	2026-06-26 01:01:23.178	\N
c1d56374-1ab0-4d51-a72c-4ef87faf70c7	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$McIZ5AnYNc5sGnLZvrQ.rOtRy7LXf4ojQQejQSfLok9kxN004qy/O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-27 13:02:34.012609	2026-06-27 17:30:49.426	\N
b28f35ed-7dfa-4b35-b83d-8724a2ee1d67	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$M5HCwhjcgp5vRCx9yNhcH.0zCk.P5Fii2kCyq3d5.gGA4cYupMMPG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 01:17:35.459838	2026-06-26 02:21:34.532	2026-06-26 01:22:56.160044
3cea3dee-36f9-4255-b3fc-5a80229842eb	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$n3NbbJEBwTx4pi8ZTU1W9uLkTAT5k2gLedEpNQ8zLCeWlOmD1G9y.	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.6	2026-07-01 12:13:03.936002	2026-07-01 13:15:25.795	\N
38c073c4-ea41-43e9-858f-5c435e88cb65	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$BSEAl7MLAODABThmFK5DxeH1Q4/aN7Siv60ggJYAyjS7DtC12jw56	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 01:25:30.124828	2026-06-26 03:12:19.662	\N
3b30c4e0-7c07-4cec-b086-22b45bc2144c	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$zEYV./mHpF/kYcXYoSBjyeZ3H6pLuJBBGwI5ltaf8cUXsrkVAfRbe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 01:26:09.354855	2026-06-26 03:12:26.497	\N
a816af73-3596-473d-8578-38b418d3c9de	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$aNJek3.V4H5aJTlX2N6PkuWfJAGOTQ4vLzxCIce2aHx3jtRlgoTdy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-27 17:59:38.152597	2026-06-28 00:22:57.842	\N
a2403865-9b11-4069-97c4-8038b33a1a5d	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$dyCXJ/JDKP.N5I.Mtes/vOdyRkqH3D.qPJQTIeCGN3uCwLKf1Lz4O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-27 14:49:01.232968	2026-06-28 00:22:59.159	\N
8171ca40-0368-465d-8989-8accdefb450d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$5h82PmaI6dEu2WhQxmXVqeAAX74TmFZ0WrB6MZCFvSdRQNSVxky2u	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-27 12:21:41.358081	2026-06-28 00:23:00.617	\N
9530ade0-9e9f-4bfc-9eff-2ae3b0777823	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$baDMa/E2kwYA6gbZ0.JwbecHwMmSSqn8ZXaQbsHsp5uk6YY8gAY5O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 14:54:25.367953	2026-06-26 19:23:04.56	\N
1d7a38d5-9ed8-4152-9fc2-877296c70141	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$psNQnY3bNSASeCYSTQRwAelXOTxNH2haxWhL1BgWs.xvuEk5.PAl.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 14:53:43.190029	2026-06-26 19:23:10.532	\N
71a3231b-74a3-4567-bf02-12bba8e8a28d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$inPcImGchLUhKsmD4JXg5ugnJeQfbhLvKUfHjryVbxEz0aH5aRZ8W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 14:44:31.6235	2026-06-26 19:23:10.562	\N
5b24821d-5373-4cf2-ba3d-7a535bf65217	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$A50/6H9s6DpiR5iW5e.I3e6vb.gaCfJTN18eJsUnGJ7Tt6/qYat/m	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 20:46:02.316746	2026-06-26 21:48:17.392	\N
7073a48b-c446-47e8-b52d-29227628650c	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$2qzTrE1wgmLt78sqrxkYX.foR7by1U2MLfELBeXl8EP4eV9AXRgO2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 08:35:46.648871	2026-06-26 14:43:06.034	\N
c62c76d5-d467-4d1b-aa78-d7809f260204	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$8rkiJbm6UmC3Orx.4IOPeOLmk1de1d.0oDNfcOQiqX2IyMqZzFDzG	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.6	2026-07-01 12:19:04.886253	2026-07-01 13:21:08.161	\N
5120ed5f-6801-40d0-bf52-c21017e30193	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$VrskDyLR6wrHbmk1Wmf5XObr.FbI3LVfZHoHMeej0yz98mOjrAt.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-26 21:53:29.008545	2026-06-26 23:29:37.136	\N
489d2f16-83f0-4518-8e95-9695a58670e9	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$7rxKdYmv9iXIbeklmxJ.YOzDPWKVSVtk0QS6WdadzeuMrkK4/3Nti	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::1	2026-06-27 11:03:43.283007	2026-06-27 12:03:42.898	\N
02c3ebb6-bbd5-40cb-ba22-20b6a09ae568	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$uny8mfclHoA9P.6AimAcH.OjDwUNlZFZ4HTK/yv5qYKyZ8HzD4Ka6	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Mobile Safari/537.36	117.18.17.106	2026-06-30 11:37:36.390566	2026-06-30 12:37:36.009	\N
1e9b8658-18c4-41cb-aff8-51cfecf33e63	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$EfHO9sBy0y4LK99apuYNJeqwyaw5lLBh6Bx.g1ljZmtdItM8VMPiq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	117.18.17.106	2026-06-30 11:29:45.487051	2026-06-30 12:41:28.389	\N
e17b1d64-7f54-48a1-a939-ecb810adb17a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$gA.xbsY7HQW0uPYg0ektQu28a3g9EfHdnHaxCRiY4ox.S.YPlrmpm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36	::ffff:192.168.1.5	2026-06-30 13:38:53.378337	2026-06-30 14:38:52.99	\N
3dcee69c-c034-48c4-a7e9-e2fbbd779eec	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$kIGMzhThkQHLtLHxg9v5oeMBlr359Fy1QZxGXho3KXI3N.A6xaWOm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::ffff:192.168.1.5	2026-07-06 11:13:28.876369	2026-07-06 12:13:28.407	2026-07-06 11:14:03.646303
79dbf40f-e7f2-43d8-ad43-aa25a9a4da2f	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$6.MputwRZJkaVqxebLXq5.qnm6F/WGxTwL5kRK1tHfELZHi1SZ9Km	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	::1	2026-10-18 07:09:48.322886	2026-10-25 09:23:50.019	2026-10-18 09:27:32.376183
6aebcebc-0961-45d7-b418-5f279c52527b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$itcWC3mw6VB.BCV/4DYSHuka9APvfCGxwEMgB5YkdV1dS8xSUadhy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	::1	2026-10-17 15:19:30.580825	2026-10-24 23:47:08.135	2026-10-17 23:47:09.053157
f546e904-02aa-4f4e-ae09-c1eb6ea8f749	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$bSMYE6P63eYJZhGt141mGOUyIqFP2TLn0XP24FklltmV02TPs9KHi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	::1	2026-10-17 20:25:08.647507	2026-10-24 22:34:18.041	\N
f5495755-1526-4d75-afbd-411647031406	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$7XHpS33ATzn3vxL7mDChleoIuGDUuE5HjaamDtZlckg8tnis3.IdK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	::1	2026-10-18 17:56:05.131209	2026-10-25 17:56:04.73	2026-10-18 18:01:10.603814
1e384aee-8cc7-4756-845d-809a09d5ba54	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$qoFWa59KFsJVyb9EYP43Muk47kDxNHQDejUDCgI8HwqWtZDODz6uy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	::1	2026-10-18 09:40:19.932923	2026-10-25 12:31:31.99	\N
ee203fd2-9392-4fa9-9de2-daec0e9213fd	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$f7KED2GZssnmsVU2MTM5Ne9ry5djLRYlFntJ/dl5m6/rltXpqF1pK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	::1	2026-10-18 18:31:57.81882	2026-10-26 00:14:07.781	2026-10-19 00:14:14.584953
ce17ea88-5cba-4881-87c4-3100e9aa676e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$mAsgSL1kbjaXffSCID88N.AMHeIPKWuos0dvfP43HXOqaWXtOs4eq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/155.0.0.0 Safari/537.36	::1	2026-10-19 12:28:20.50379	2026-10-26 13:52:55.326	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id_user, username, password, role, created_at, updated_at) FROM stdin;
4f9150c7-e6ed-4ea2-8690-4fb9f699240c	admin1	$2b$10$24w2UBPmdFI08MFkI2BdJuH.6tPsE1ms2TleJ6dDc6a.CpviGkpIG	admin	2025-05-14 15:25:48.154028	2025-06-24 12:02:52.098328
81caf204-9368-484b-b200-f9d4bde5c87b	kasir1	$2b$10$BWmhgYt1omdWSQTmNWGdjOwN80RRmTM/CiMW7ksjKu20NVp0nbde2	kasir	2025-06-05 18:25:21.751292	2025-06-25 19:11:59.792706
6181ac3f-3415-4dc9-ba6f-69be692100fa	owner	$2b$10$xboSPXjix4wQ228vaj.j1eHeiG/fxIFHTPb9hccMPUEVwIoEkbEve	owner	2025-11-06 18:21:31.6297	2025-11-06 18:21:31.6297
\.


--
-- Name: barang_masuk barang_masuk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.barang_masuk
    ADD CONSTRAINT barang_masuk_pkey PRIMARY KEY (id_barang_masuk);


--
-- Name: barang barang_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.barang
    ADD CONSTRAINT barang_pkey PRIMARY KEY (id_barang);


--
-- Name: detail_transaksi detail_transaksi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detail_transaksi
    ADD CONSTRAINT detail_transaksi_pkey PRIMARY KEY (id_detail_transaksi);


--
-- Name: fcm_tokens fcm_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fcm_tokens
    ADD CONSTRAINT fcm_tokens_pkey PRIMARY KEY (id_fcm_token);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id_notification);


--
-- Name: pelanggan pelanggan_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pelanggan
    ADD CONSTRAINT pelanggan_pkey PRIMARY KEY (id_pelanggan);


--
-- Name: histori_tukar_poin pk_histori_tukar_poin; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.histori_tukar_poin
    ADD CONSTRAINT pk_histori_tukar_poin PRIMARY KEY (id_histori_tukar);


--
-- Name: transaksi transaksi_kode_transaksi_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_kode_transaksi_key UNIQUE (kode_transaksi);


--
-- Name: transaksi transaksi_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_pkey PRIMARY KEY (id_transaksi);


--
-- Name: pelanggan unique_nama_pelanggan; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pelanggan
    ADD CONSTRAINT unique_nama_pelanggan UNIQUE (nama_pelanggan);


--
-- Name: pelanggan unique_no_hp; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pelanggan
    ADD CONSTRAINT unique_no_hp UNIQUE (no_hp);


--
-- Name: fcm_tokens uq_fcm_tokens_token; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fcm_tokens
    ADD CONSTRAINT uq_fcm_tokens_token UNIQUE (fcm_token);


--
-- Name: user_sessions user_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_pkey PRIMARY KEY (session_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id_user);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: idx_barang_masuk_date; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_barang_masuk_date ON public.barang_masuk USING btree (created_at);


--
-- Name: idx_barang_masuk_id_barang; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_barang_masuk_id_barang ON public.barang_masuk USING btree (id_barang);


--
-- Name: idx_fcm_tokens_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_fcm_tokens_user ON public.fcm_tokens USING btree (id_user);


--
-- Name: idx_notifications_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_created_at ON public.notifications USING btree (created_at DESC);


--
-- Name: idx_notifications_metadata; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_notifications_metadata ON public.notifications USING gin (metadata);


--
-- Name: idx_user_sessions_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_user_sessions_user ON public.user_sessions USING btree (user_id);


--
-- Name: barang trigger_update_barang_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_barang_updated_at BEFORE UPDATE ON public.barang FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: detail_transaksi trigger_update_detail_transaksi; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trigger_update_detail_transaksi BEFORE UPDATE ON public.detail_transaksi FOR EACH ROW EXECUTE FUNCTION public.update_detail_transaksi_timestamp();


--
-- Name: pelanggan update_pelanggan_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_pelanggan_updated_at BEFORE UPDATE ON public.pelanggan FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: transaksi update_transaksi_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_transaksi_updated_at BEFORE UPDATE ON public.transaksi FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: users update_users_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: detail_transaksi detail_transaksi_id_transaksi_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.detail_transaksi
    ADD CONSTRAINT detail_transaksi_id_transaksi_fkey FOREIGN KEY (id_transaksi) REFERENCES public.transaksi(id_transaksi) ON DELETE CASCADE;


--
-- Name: fcm_tokens fcm_tokens_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fcm_tokens
    ADD CONSTRAINT fcm_tokens_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id_user) ON DELETE CASCADE;


--
-- Name: barang_masuk fk_barang_masuk_barang; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.barang_masuk
    ADD CONSTRAINT fk_barang_masuk_barang FOREIGN KEY (id_barang) REFERENCES public.barang(id_barang) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: histori_tukar_poin fk_histori_pelanggan; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.histori_tukar_poin
    ADD CONSTRAINT fk_histori_pelanggan FOREIGN KEY (id_pelanggan) REFERENCES public.pelanggan(id_pelanggan) ON DELETE SET NULL;


--
-- Name: notifications fk_notifications_actor; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_notifications_actor FOREIGN KEY (actor_user_id) REFERENCES public.users(id_user) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: transaksi transaksi_id_user_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_id_user_fkey FOREIGN KEY (id_user) REFERENCES public.users(id_user);


--
-- Name: transaksi transaksi_pelanggan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.transaksi
    ADD CONSTRAINT transaksi_pelanggan_fkey FOREIGN KEY (id_pelanggan) REFERENCES public.pelanggan(id_pelanggan);


--
-- Name: user_sessions user_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_sessions
    ADD CONSTRAINT user_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id_user) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict t89FiQrOrpW24mNOysQXvA79cg3Qcsl2rNed3FrPGy3gr2zu5BZMRvw1ns3LBwL

