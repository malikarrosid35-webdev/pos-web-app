--
-- PostgreSQL database dump
--

\restrict EQE0Bl4slAcBhigARoV5IT3W0C0wyFrslAxgMFxlZ0dAi2e3rXIj8fGflmFcT06

-- Dumped from database version 18.6 (Debian 18.6-1.pgdg13+2)
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
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


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
    image_barang character varying(255),
    nama_barang character varying(100) NOT NULL,
    kategori_barang character varying(50) NOT NULL,
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
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    metadata jsonb
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

COPY public.barang (id_barang, image_barang, nama_barang, kategori_barang, created_at, updated_at, stok_dasar, harga_jual_per_sd, harga_modal_per_sd, satuan_dasar) FROM stdin;
f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	/uploads/images/77f41e63-2ffd-46fb-bbb9-ea50824a6066.jpg	Tepung Terigu Eceran	Tepung Eceran	2026-05-07 12:36:54.383173	2026-07-26 19:47:04.509128	1900	12.00	10.00	GRAM
1cfb51d0-5112-4705-a799-f60cf468dd8b	/uploads/images/c83246f3-f8ac-4371-8838-19d091de9528.jpg	Teh Pucuk Harum	Minuman Botol	2025-04-28 12:45:35.705379	2026-05-05 10:44:49.277098	10	3000.00	2250.00	PCS
c4192c7f-2af1-42ea-94f2-8f9f0118f96a	\N	Kemiri	Bumbu Dapur	2026-09-10 12:18:47.446991	2026-09-10 12:26:26.956343	250	80.00	50.00	GRAM
78228c66-13c3-4a24-b80b-13b467f2e2c4	/uploads/images/4ea5f59c-066a-4251-924a-729f6837d38b.jpg	Sampo Lifebuoy Sachet	Sampo	2026-05-07 10:13:47.863343	2026-05-07 15:43:43.523313	9	500.00	400.00	PCS
f242383f-3a55-4837-bb1a-45106102140c	/uploads/images/09c2766a-30e3-43c7-a6fa-c7ab7f1c611f.png	Bawang Merah	Bumbu Dapur	2026-05-05 13:21:40.055039	2026-05-07 15:49:40.554082	100	50.00	44.00	GRAM
3c5efe24-3b54-4684-8d85-9f04281bb1f7	/uploads/images/3070adf0-2914-40e2-9c76-65437c651729.jpg	Sunco 1 L	Minyak Goreng	2025-04-28 15:42:36.54209	2026-09-24 07:51:59.352706	13	18000.00	13500.00	PCS
57cedf50-ccb5-4124-92ba-5cf4e3c2d860	/uploads/images/b2a0aff9-2e3b-4933-abc0-09481f0c231a.jpg	Beras Cap Raja Lele	Makanan Pokok	2026-02-04 23:38:41.194263	2026-09-24 07:57:24.838633	13000	14.00	13.20	GRAM
f76d3939-fc78-460f-a05f-17f06de7dd5f	/uploads/images/324f0c19-98ac-4fd6-9175-dcbb336c246c.webp	Dedak	Pakan Ternak Unggas	2026-01-26 21:46:09.264955	2026-09-24 07:58:22.847907	9500	5.00	4.00	GRAM
d8e3e01b-7236-430d-82d4-3a9d6dea0252	/uploads/images/3476819e-856c-4aee-ae4b-cef656048d42.jpg	Good Day Cappuccino 25gr	Kopi Sachet	2025-12-29 22:23:05.939615	2026-09-24 07:59:02.359846	10	3000.00	2000.00	PCS
b5f3db31-5a02-4ce5-891d-cfb9d05c2428	/uploads/images/0555ac76-4d50-4598-969d-a064f0ea83c5.jpg	Kopi Luwak Hitam	Kopi Sachet	2025-05-02 13:28:55.700105	2026-09-24 07:59:33.022194	10	1000.00	750.00	PCS
fa5ba8f3-3b16-4d8d-a784-a2286ef8ee44	/uploads/images/52be53be-bd49-4aba-aa42-765edec99890.webp	Bawang Putih	Bumbu Dapur	2026-05-05 13:06:04.075218	2026-09-24 08:04:31.38555	220	35.00	30.00	GRAM
75918d03-7fea-47b0-8c25-b9b726d165ce	/uploads/images/be615633-cdf7-4810-8e33-ad5fc0b63df3.jpg	Cabai Rawit	Bumbu Dapur	2025-04-27 20:04:24.978449	2026-09-24 08:06:25.732349	240	90.00	80.00	GRAM
27c534ab-74ba-4d53-a099-8b4ce4e6339d	/uploads/images/1e836ea9-a5b4-46a3-87a6-75011468295c.png	Cabai Merah Keriting	Bumbu Dapur	2026-05-05 16:38:19.598022	2026-09-24 08:07:44.981594	220	70.00	60.00	GRAM
9dfd11c5-0bf4-42de-b88b-1340c2249965	/uploads/images/8492a385-3a5e-49e3-a091-476c9552d4ea.jpg	Beras Parimas	Makanan Pokok	2026-02-04 23:36:19.929226	2026-09-24 08:08:44.092377	13000	14.00	13.00	GRAM
52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	/uploads/images/caa1661d-d7c4-48fb-b501-a893fb3024b2.jpg	Mie Sedap Goreng	Mie Instan	2025-04-28 12:47:21.689056	2026-09-24 08:09:29.286023	10	3500.00	2625.00	PCS
00ad5437-d4d1-4af7-88ac-eb283c3bccac	/uploads/images/65bc50d7-2b5e-4dcd-b25d-3719fe4da218.png	Indomie Goreng	Mie Instan	2025-04-28 15:41:54.803812	2026-09-24 08:18:46.677406	13	3500.00	3000.00	PCS
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
06b17603-326d-4226-96e7-e467d6e7ef6e	c4192c7f-2af1-42ea-94f2-8f9f0118f96a	250	12500.00	50.00	2026-09-10 12:18:47.446991
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
ffcfcf55-5289-4333-8313-0733b7fd1ac4	0ddddf5c-209e-4428-9d43-8c9bb3864db9	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	1000	14000	2026-07-24 11:06:04.783715	2026-07-24 11:06:04.783715
1a0f116c-4f3b-4447-8d2d-a73c42931652	3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-07-26 17:04:43.77789	2026-07-26 17:04:43.77789
406b7eac-f972-4d5f-98e4-ef0f9c87efa6	26e33d69-6fb5-493c-a616-01df636d2914	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	2	7000	2026-07-26 17:14:26.601368	2026-07-26 17:14:26.601368
794ed7bd-3201-4436-ab9b-04461904eef4	33502004-9e0f-4fa0-bad2-53b7ed424d02	52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	3500.00	3	10500	2026-07-26 19:53:20.687442	2026-07-26 19:53:20.687442
fe66d2f2-c6f6-420f-a2b2-ab4273a7cf4e	0ab50f49-8898-48fb-abe0-3c76afeeb8b3	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	2000	28000	2026-07-26 19:55:29.600453	2026-07-26 19:55:29.600453
3fbe8e7f-358d-4a95-a684-078ab141df3a	cb04caad-817a-4ff5-9d8d-6a1da25f3c5d	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	2	6000	2026-09-13 09:42:17.712029	2026-09-13 09:42:17.712029
127286eb-0272-40cd-aaa5-5b543dfec203	635a7da3-f04b-4b76-b5c5-f32b103fe84b	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	1	3500	2026-09-22 14:21:06.285058	2026-09-22 14:21:06.285058
951966be-ffc0-4fc3-aa19-a4a9448988e5	635a7da3-f04b-4b76-b5c5-f32b103fe84b	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-09-22 14:21:06.285058	2026-09-22 14:21:06.285058
d039a218-cdff-42a8-b73b-591cb81679ac	d4921c24-9f9b-4869-aa69-965e26fc5e83	f76d3939-fc78-460f-a05f-17f06de7dd5f	Dedak	5.00	1000	5000	2026-09-22 14:22:52.568676	2026-09-22 14:22:52.568676
ef7ffcee-21cf-4ccf-9639-14e9f9f952b6	baf7b66b-bfd6-4285-9790-63d446bf965d	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	1	3500	2026-09-24 01:30:38.19539	2026-09-24 01:30:38.19539
3bde8355-7418-4abf-9a40-0d615f5c7e99	baf7b66b-bfd6-4285-9790-63d446bf965d	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	1000	14000	2026-09-24 01:30:38.19539	2026-09-24 01:30:38.19539
aef41aa8-c8dc-42d7-90dc-626310801b1b	f6c2d69d-b6b6-4429-a426-7ef43ecf468c	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	1500	21000	2026-09-24 03:01:40.020623	2026-09-24 03:01:40.020623
062ce7bd-1d2c-4c54-a8fe-270e4845e4ee	68718128-2a4f-43c6-967d-ef76d33a0fd3	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-09-24 03:19:40.429358	2026-09-24 03:19:40.429358
803f5ff6-081c-4107-a746-7a5fb2b4f436	5e15ecd6-71f7-4081-85df-87df98168335	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-09-24 07:49:31.548003	2026-09-24 07:49:31.548003
a55c21f5-df02-4976-9ada-0b112ae5d31c	3e3e6625-beb5-446d-8909-130dcbc47275	f76d3939-fc78-460f-a05f-17f06de7dd5f	Dedak	5.00	1000	5000	2026-09-24 07:50:56.237191	2026-09-24 07:50:56.237191
6a3486b4-e6f6-44c5-afed-39be3ff60410	d7993f5e-40f8-411f-9704-eadd7eb8cb8b	3c5efe24-3b54-4684-8d85-9f04281bb1f7	Sunco 1 L	18000.00	1	18000	2026-09-24 07:51:59.352706	2026-09-24 07:51:59.352706
bdd19fae-3dcf-4c39-827a-051d01feb047	1a492d49-b2bf-4541-a3d8-1425b4e5f935	57cedf50-ccb5-4124-92ba-5cf4e3c2d860	Beras Cap Raja Lele	14.00	1500	21000	2026-09-24 07:57:24.838633	2026-09-24 07:57:24.838633
6eb613a7-8ff9-4d6d-9320-36ed29628584	bd3f581c-5e74-485e-8501-b95707c9eedc	f76d3939-fc78-460f-a05f-17f06de7dd5f	Dedak	5.00	500	2500	2026-09-24 07:58:22.847907	2026-09-24 07:58:22.847907
e32e9816-89ba-4098-b089-62dd79405851	76f355f4-7b86-4b0d-aa8d-aa1b3bac6e09	d8e3e01b-7236-430d-82d4-3a9d6dea0252	Good Day Cappuccino 25gr	3000.00	1	3000	2026-09-24 07:59:02.359846	2026-09-24 07:59:02.359846
0de89bfb-1fd0-44f5-893a-deedca6576a5	a2b62f0e-9095-4874-bd31-aeb9ebdb4b55	b5f3db31-5a02-4ce5-891d-cfb9d05c2428	Kopi Luwak Hitam	1000.00	2	2000	2026-09-24 07:59:33.022194	2026-09-24 07:59:33.022194
63e92b49-0710-43fd-99b2-4abdcd891c71	bea35d51-0ea1-475d-b7d9-5b269718e12d	fa5ba8f3-3b16-4d8d-a784-a2286ef8ee44	Bawang Putih	35.00	30	1500	2026-09-24 08:04:31.38555	2026-09-24 08:04:31.38555
d437e424-2381-4460-9a3c-9cac0b3ddf82	57de1ae1-7e24-44cf-83b0-1516acd5d8d1	75918d03-7fea-47b0-8c25-b9b726d165ce	Cabai Rawit	90.00	30	3000	2026-09-24 08:06:25.732349	2026-09-24 08:06:25.732349
8ca96f1b-6904-4200-a69c-a81d7f67b361	2e86384d-3004-4cd2-9f35-a7b21979f030	27c534ab-74ba-4d53-a099-8b4ce4e6339d	Cabai Merah Keriting	70.00	30	2500	2026-09-24 08:07:44.981594	2026-09-24 08:07:44.981594
ec13301b-a320-42c3-b0d5-39a40cf2ebfc	e75b13b5-e746-4933-b108-ea9c29f72e08	9dfd11c5-0bf4-42de-b88b-1340c2249965	Beras Parimas	14.00	1000	14000	2026-09-24 08:08:44.092377	2026-09-24 08:08:44.092377
6473dc44-3274-4860-b48a-b36ad1d76d49	84f90a4f-f2f3-448b-9d15-56720e4e6d86	52fb92f4-2320-4fc8-986c-96f9d9cc3c7d	Mie Sedap Goreng	3500.00	1	3500	2026-09-24 08:09:29.286023	2026-09-24 08:09:29.286023
46c48ec7-6006-48d7-b01a-460bb496c0bf	99c8a56e-a1a2-4787-b396-997b9f003757	00ad5437-d4d1-4af7-88ac-eb283c3bccac	Indomie Goreng	3500.00	1	3500	2026-09-24 08:18:46.677406	2026-09-24 08:18:46.677406
\.


--
-- Data for Name: fcm_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fcm_tokens (id_fcm_token, id_user, fcm_token, device_info, created_at, updated_at) FROM stdin;
8c065e79-2ed6-49c5-b334-4f91f43725e2	6181ac3f-3415-4dc9-ba6f-69be692100fa	eAwPYUK_lKpIngWQA2HKRf:APA91bFll4Ez29hYttm9OsP_j5JTvCjhCLIEQybYVR3RTBaBhHV1sXZ3f6qIrKv3UI0YAgVxHAAqiMAYIhWS9qA7KVrOG4KlR47wAnRAV683LAivXGMB7Hc	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	2026-09-29 05:42:10.381056	2026-09-29 05:56:46.458395
53f46b3e-7751-4500-8797-293c90ccf4c0	6181ac3f-3415-4dc9-ba6f-69be692100fa	ea2pkJ--xQb03xxMmXhs9S:APA91bGZVPmnlRizYKjAVfyjYl2oQ3ZtzjkiDpOD_tSyaJiZd22P1DsOrRjHEN5MDUIMAZpOifZg_HrWTVEuWVw1XRzGD8xd8cJdKx89t4Q4795wSigrc2k	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	2026-09-24 10:57:55.102706	2026-09-27 14:17:13.469191
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id_notification, title, message, notification_type, reference_table, reference_id, actor_user_id, is_read, created_at, metadata) FROM stdin;
6698b2a3-924e-448e-8b01-05fec7080092	Laporan Harian Toko	Laporan harian 2026-07-23: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-07-23 12:42:00.012765	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-07-23", "generated_at": "2026-07-23T05:42:00.011Z", "highest_transaction": null}
e2ba078a-43c3-4762-b5ae-243968a5f90d	Laporan Harian Toko	Laporan harian 2026-07-26: total penjualan Rp 21.000 dari 2 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-07-26 17:52:15.187784	{"summary": {"total_sales": 21000, "total_transactions": 2, "total_guest_transactions": 2, "total_member_transactions": 0}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a", "customer_name": "guest-B8CD5A", "customer_type": "guest", "kode_transaksi": "TRX-B8CD5A", "id_detail_transaksi": "1a0f116c-4f3b-4447-8d2d-a73c42931652"}, {"quantity": 2, "subtotal": 7000, "item_name": "Indomie Goreng", "id_transaksi": "26e33d69-6fb5-493c-a616-01df636d2914", "customer_name": "guest-6D2914", "customer_type": "guest", "kode_transaksi": "TRX-6D2914", "id_detail_transaksi": "406b7eac-f972-4d5f-98e4-ef0f9c87efa6"}], "report_date": "2026-07-26", "generated_at": "2026-07-26T10:52:15.175Z", "highest_transaction": {"total_harga": 14000, "id_transaksi": "3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a", "customer_name": "guest-B8CD5A", "customer_type": "guest", "kode_transaksi": "TRX-B8CD5A"}}
7e9a3a67-f177-4c7c-9290-e8fe26f627c1	Data Barang Diperbarui	Admin admin1 memperbarui data barang "Tepung Terigu".	PRODUCT_UPDATED	barang	f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	t	2026-07-26 16:31:24.305788	{"id_barang": "f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4", "updated_fields": ["nama_barang", "kategori_barang", "harga_jual_per_sd"]}
350a3e24-c32e-49da-afad-0200a41c6814	Data Barang Diperbarui	Admin admin1 memperbarui data barang "Tepung Terigu". Perubahan: harga jual dari Rp13 menjadi Rp12.	PRODUCT_UPDATED	barang	f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	t	2026-07-26 19:33:56.053654	{"id_barang": "f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4", "updated_fields": ["nama_barang", "kategori_barang", "harga_jual_per_sd"], "changed_attributes": ["harga_jual_per_sd"], "harga_jual_per_sd_sebelum": "13.00", "harga_jual_per_sd_sesudah": "12.00"}
666e2d25-6b6c-46ec-9adf-ee53ce5ef3d8	Data Member Diperbarui	Kasir kasir1 memperbarui data member pelanggan "Ibu Budi".	MEMBER_UPDATED	pelanggan	19ec6aa0-28df-4b03-92ba-418d1cc86953	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-07-26 19:50:50.509264	{"id_pelanggan": "19ec6aa0-28df-4b03-92ba-418d1cc86953", "updated_fields": ["nama_pelanggan", "no_hp"]}
ad2026d9-2a6c-43ec-b0d0-fca78c83b902	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-EEB8B3 sebesar Rp28.000 atas nama "guest-EEB8B3".	TRANSACTION_CREATED	transaksi	0ab50f49-8898-48fb-abe0-3c76afeeb8b3	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-07-26 19:55:31.608245	{"total_harga": 28000, "id_transaksi": "0ab50f49-8898-48fb-abe0-3c76afeeb8b3", "kode_transaksi": "TRX-EEB8B3", "tipe_pelanggan": "guest"}
bb338aec-575b-41a3-9b0f-45d5f410638a	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-B8CD5A sebesar - atas nama -.	TRANSACTION_CREATED	transaksi	3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-07-26 17:04:46.221424	{"total_harga": 14000, "id_transaksi": "3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a", "kode_transaksi": "TRX-B8CD5A", "tipe_pelanggan": "guest"}
87e2526c-8207-4660-9727-50b970383db2	Laporan Harian Toko	Laporan harian 2026-07-26: total penjualan Rp 21.000 dari 2 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-07-26 17:52:20.022208	{"summary": {"total_sales": 21000, "total_transactions": 2, "total_guest_transactions": 2, "total_member_transactions": 0}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a", "customer_name": "guest-B8CD5A", "customer_type": "guest", "kode_transaksi": "TRX-B8CD5A", "id_detail_transaksi": "1a0f116c-4f3b-4447-8d2d-a73c42931652"}, {"quantity": 2, "subtotal": 7000, "item_name": "Indomie Goreng", "id_transaksi": "26e33d69-6fb5-493c-a616-01df636d2914", "customer_name": "guest-6D2914", "customer_type": "guest", "kode_transaksi": "TRX-6D2914", "id_detail_transaksi": "406b7eac-f972-4d5f-98e4-ef0f9c87efa6"}], "report_date": "2026-07-26", "generated_at": "2026-07-26T10:52:20.014Z", "highest_transaction": {"total_harga": 14000, "id_transaksi": "3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a", "customer_name": "guest-B8CD5A", "customer_type": "guest", "kode_transaksi": "TRX-B8CD5A"}}
64b62c14-92a6-4b76-99d6-0b778b87ad51	Data Barang Diperbarui	Admin admin1 memperbarui data barang "Tepung Terigu". Perubahan: harga jual dari Rp12 menjadi Rp13 per GRAM.	PRODUCT_UPDATED	barang	f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	t	2026-07-26 19:46:16.575718	{"id_barang": "f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4", "updated_fields": ["nama_barang", "kategori_barang", "harga_jual_per_sd"], "changed_attributes": ["harga_jual_per_sd"], "harga_jual_per_sd_sebelum": "12.00", "harga_jual_per_sd_sesudah": "13.00"}
d93ec6bc-d18a-41f1-9abd-84b55a8acd1c	Data Member Diperbarui	Kasir kasir1 memperbarui data member pelanggan "pelanggan4".	MEMBER_UPDATED	pelanggan	19ec6aa0-28df-4b03-92ba-418d1cc86953	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-07-26 19:51:45.53	{"id_pelanggan": "19ec6aa0-28df-4b03-92ba-418d1cc86953", "updated_fields": ["nama_pelanggan", "no_hp"]}
5b7ffe2e-2cd5-4e20-9d22-098d5dfeeecf	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-BF965D sebesar Rp17.500 atas nama "guest-BF965D".	TRANSACTION_CREATED	transaksi	baf7b66b-bfd6-4285-9790-63d446bf965d	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 01:30:38.219508	{"total_harga": 17500, "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "kode_transaksi": "TRX-BF965D", "tipe_pelanggan": "guest"}
603cf6ae-2295-4cc3-ab18-8bb9a1a74a8e	Laporan Harian Toko	Laporan harian 2026-09-24: total penjualan Rp 17.500 dari 1 transaksi.	REPORT_DAILY	\N	\N	\N	f	2026-09-24 03:00:00.193603	{"summary": {"total_sales": 17500, "total_transactions": 1, "total_guest_transactions": 1, "total_member_transactions": 0}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "3bde8355-7418-4abf-9a40-0d615f5c7e99"}, {"quantity": 1, "subtotal": 3500, "item_name": "Indomie Goreng", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "ef7ffcee-21cf-4ccf-9639-14e9f9f952b6"}], "report_date": "2026-09-24", "generated_at": "2026-09-24T03:00:00.160Z", "highest_transaction": {"total_harga": 17500, "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D"}}
1e2c4e90-1428-4164-8642-d5b10db7ac4f	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-CF468C sebesar Rp21.000 atas nama "pelanggan5".	TRANSACTION_CREATED	transaksi	f6c2d69d-b6b6-4429-a426-7ef43ecf468c	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 03:01:40.057649	{"total_harga": 21000, "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "kode_transaksi": "TRX-CF468C", "tipe_pelanggan": "member"}
ec8d9de0-490b-46c5-9e4b-ef5860eaf512	Data Barang Diperbarui	Admin admin1 memperbarui data barang "Tepung Terigu Eceran". Perubahan: nama barang dari "Tepung Terigu" menjadi "Tepung Terigu Eceran"; harga jual dari Rp13 menjadi Rp12 per GRAM.	PRODUCT_UPDATED	barang	f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	t	2026-07-26 19:47:04.516995	{"id_barang": "f06dd4ba-207e-4f1d-b71c-19b7f58fb5f4", "updated_fields": ["nama_barang", "kategori_barang", "harga_jual_per_sd"], "changed_attributes": ["nama_barang", "harga_jual_per_sd"], "nama_barang_sebelum": "Tepung Terigu", "nama_barang_sesudah": "Tepung Terigu Eceran", "harga_jual_per_sd_sebelum": "13.00", "harga_jual_per_sd_sesudah": "12.00"}
11028090-1edb-49d2-ad95-5cfe15914501	Laporan Harian Toko	Laporan harian 2026-07-23: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-07-23 12:41:55.021271	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-07-23", "generated_at": "2026-07-23T05:41:55.019Z", "highest_transaction": null}
47938d98-03a7-4047-a904-8a14daa6c31c	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-6D2914 sebesar 7000 atas nama guest-6D2914.	TRANSACTION_CREATED	transaksi	26e33d69-6fb5-493c-a616-01df636d2914	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-07-26 17:14:28.543567	{"total_harga": 7000, "id_transaksi": "26e33d69-6fb5-493c-a616-01df636d2914", "kode_transaksi": "TRX-6D2914", "tipe_pelanggan": "guest"}
f8a4e480-e1e3-45b3-8e25-3dd5b0870d7f	Laporan Harian Toko	Laporan harian 2026-07-26: total penjualan Rp 21.000 dari 2 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-07-26 17:52:25.013693	{"summary": {"total_sales": 21000, "total_transactions": 2, "total_guest_transactions": 2, "total_member_transactions": 0}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a", "customer_name": "guest-B8CD5A", "customer_type": "guest", "kode_transaksi": "TRX-B8CD5A", "id_detail_transaksi": "1a0f116c-4f3b-4447-8d2d-a73c42931652"}, {"quantity": 2, "subtotal": 7000, "item_name": "Indomie Goreng", "id_transaksi": "26e33d69-6fb5-493c-a616-01df636d2914", "customer_name": "guest-6D2914", "customer_type": "guest", "kode_transaksi": "TRX-6D2914", "id_detail_transaksi": "406b7eac-f972-4d5f-98e4-ef0f9c87efa6"}], "report_date": "2026-07-26", "generated_at": "2026-07-26T10:52:25.006Z", "highest_transaction": {"total_harga": 14000, "id_transaksi": "3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a", "customer_name": "guest-B8CD5A", "customer_type": "guest", "kode_transaksi": "TRX-B8CD5A"}}
ddfe244d-3139-46bf-8259-7f931b21a649	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-424D02 sebesar Rp10,500 atas nama "pelanggan5".	TRANSACTION_CREATED	transaksi	33502004-9e0f-4fa0-bad2-53b7ed424d02	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-07-26 19:53:23.401667	{"total_harga": 10500, "id_transaksi": "33502004-9e0f-4fa0-bad2-53b7ed424d02", "kode_transaksi": "TRX-424D02", "tipe_pelanggan": "member"}
8cd625fa-78c2-483e-99a9-536b85a556aa	Laporan Harian Toko	Laporan harian 2026-09-24: total penjualan Rp 38.500 dari 2 transaksi.	REPORT_DAILY	\N	\N	\N	f	2026-09-24 03:10:00.062217	{"summary": {"total_sales": 38500, "total_transactions": 2, "total_guest_transactions": 1, "total_member_transactions": 1}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "3bde8355-7418-4abf-9a40-0d615f5c7e99"}, {"quantity": 1, "subtotal": 3500, "item_name": "Indomie Goreng", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "ef7ffcee-21cf-4ccf-9639-14e9f9f952b6"}, {"quantity": 1500, "subtotal": 21000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C", "id_detail_transaksi": "aef41aa8-c8dc-42d7-90dc-626310801b1b"}], "report_date": "2026-09-24", "generated_at": "2026-09-24T03:10:00.059Z", "highest_transaction": {"total_harga": 21000, "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C"}}
7e629ee0-90e6-4f6b-bb89-0d9253df5d44	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:09:35.092715	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:09:35.086Z", "highest_transaction": null}
61acbe75-53b4-4e0d-8133-1cd03db02563	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-3A0FD3 sebesar Rp14.000 atas nama "pelanggan6".	TRANSACTION_CREATED	transaksi	68718128-2a4f-43c6-967d-ef76d33a0fd3	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 03:19:40.479043	{"total_harga": 14000, "id_transaksi": "68718128-2a4f-43c6-967d-ef76d33a0fd3", "kode_transaksi": "TRX-3A0FD3", "tipe_pelanggan": "member"}
ada8429f-a2af-47f5-bd9e-828739822713	Laporan Harian Toko	Laporan harian 2026-09-24: total penjualan Rp 52.500 dari 3 transaksi.	REPORT_DAILY	\N	\N	\N	f	2026-09-24 03:20:00.291376	{"summary": {"total_sales": 52500, "total_transactions": 3, "total_guest_transactions": 1, "total_member_transactions": 2}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "3bde8355-7418-4abf-9a40-0d615f5c7e99"}, {"quantity": 1, "subtotal": 3500, "item_name": "Indomie Goreng", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "ef7ffcee-21cf-4ccf-9639-14e9f9f952b6"}, {"quantity": 1500, "subtotal": 21000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C", "id_detail_transaksi": "aef41aa8-c8dc-42d7-90dc-626310801b1b"}, {"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "68718128-2a4f-43c6-967d-ef76d33a0fd3", "customer_name": "pelanggan6", "customer_type": "member", "kode_transaksi": "TRX-3A0FD3", "id_detail_transaksi": "062ce7bd-1d2c-4c54-a8fe-270e4845e4ee"}], "report_date": "2026-09-24", "generated_at": "2026-09-24T03:20:00.287Z", "highest_transaction": {"total_harga": 21000, "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C"}}
888b4b07-10de-400e-9d92-f33f30a2b538	Laporan Harian Toko	Laporan harian 2026-09-24: total penjualan Rp 52.500 dari 3 transaksi.	REPORT_DAILY	\N	\N	\N	f	2026-09-24 03:25:00.156977	{"summary": {"total_sales": 52500, "total_transactions": 3, "total_guest_transactions": 1, "total_member_transactions": 2}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "3bde8355-7418-4abf-9a40-0d615f5c7e99"}, {"quantity": 1, "subtotal": 3500, "item_name": "Indomie Goreng", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "ef7ffcee-21cf-4ccf-9639-14e9f9f952b6"}, {"quantity": 1500, "subtotal": 21000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C", "id_detail_transaksi": "aef41aa8-c8dc-42d7-90dc-626310801b1b"}, {"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "68718128-2a4f-43c6-967d-ef76d33a0fd3", "customer_name": "pelanggan6", "customer_type": "member", "kode_transaksi": "TRX-3A0FD3", "id_detail_transaksi": "062ce7bd-1d2c-4c54-a8fe-270e4845e4ee"}], "report_date": "2026-09-24", "generated_at": "2026-09-24T03:25:00.112Z", "highest_transaction": {"total_harga": 21000, "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C"}}
8870dbf4-e887-4354-9ef3-943fca3c49a2	Laporan Harian Toko	Laporan harian 2026-09-24: total penjualan Rp 52.500 dari 3 transaksi.	REPORT_DAILY	\N	\N	\N	f	2026-09-24 04:00:00.216942	{"summary": {"total_sales": 52500, "total_transactions": 3, "total_guest_transactions": 1, "total_member_transactions": 2}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "3bde8355-7418-4abf-9a40-0d615f5c7e99"}, {"quantity": 1, "subtotal": 3500, "item_name": "Indomie Goreng", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "ef7ffcee-21cf-4ccf-9639-14e9f9f952b6"}, {"quantity": 1500, "subtotal": 21000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C", "id_detail_transaksi": "aef41aa8-c8dc-42d7-90dc-626310801b1b"}, {"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "68718128-2a4f-43c6-967d-ef76d33a0fd3", "customer_name": "pelanggan6", "customer_type": "member", "kode_transaksi": "TRX-3A0FD3", "id_detail_transaksi": "062ce7bd-1d2c-4c54-a8fe-270e4845e4ee"}], "report_date": "2026-09-24", "generated_at": "2026-09-24T04:00:00.153Z", "highest_transaction": {"total_harga": 21000, "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C"}}
7b87d8a0-0c78-48b9-8676-f26f744c33ef	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-168335 sebesar Rp14.000 atas nama "guest-168335".	TRANSACTION_CREATED	transaksi	5e15ecd6-71f7-4081-85df-87df98168335	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 07:49:31.604538	{"total_harga": 14000, "id_transaksi": "5e15ecd6-71f7-4081-85df-87df98168335", "kode_transaksi": "TRX-168335", "tipe_pelanggan": "guest"}
f74c8540-7cc7-4116-926e-93be86ea1f6a	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-C47275 sebesar Rp5.000 atas nama "pelanggan7".	TRANSACTION_CREATED	transaksi	3e3e6625-beb5-446d-8909-130dcbc47275	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 07:50:56.278412	{"total_harga": 5000, "id_transaksi": "3e3e6625-beb5-446d-8909-130dcbc47275", "kode_transaksi": "TRX-C47275", "tipe_pelanggan": "member"}
84cda970-d248-42e6-a602-cc4b356ba30c	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-B8CB8B sebesar Rp18.000 atas nama "guest-B8CB8B".	TRANSACTION_CREATED	transaksi	d7993f5e-40f8-411f-9704-eadd7eb8cb8b	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-24 07:51:59.383991	{"total_harga": 18000, "id_transaksi": "d7993f5e-40f8-411f-9704-eadd7eb8cb8b", "kode_transaksi": "TRX-B8CB8B", "tipe_pelanggan": "guest"}
0ae7e187-e7e1-4cf0-9423-4bff01721688	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-E5F935 sebesar Rp21.000 atas nama "pelanggan8".	TRANSACTION_CREATED	transaksi	1a492d49-b2bf-4541-a3d8-1425b4e5f935	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 07:57:24.877996	{"total_harga": 21000, "id_transaksi": "1a492d49-b2bf-4541-a3d8-1425b4e5f935", "kode_transaksi": "TRX-E5F935", "tipe_pelanggan": "member"}
aca7f5d6-321f-43b8-b861-6e59c442170a	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-C9EEDC sebesar Rp2.500 atas nama "guest-C9EEDC".	TRANSACTION_CREATED	transaksi	bd3f581c-5e74-485e-8501-b95707c9eedc	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 07:58:22.874036	{"total_harga": 2500, "id_transaksi": "bd3f581c-5e74-485e-8501-b95707c9eedc", "kode_transaksi": "TRX-C9EEDC", "tipe_pelanggan": "guest"}
6735d2f0-ec85-4586-8893-f31e76492ac1	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-AC6E09 sebesar Rp3.000 atas nama "guest-AC6E09".	TRANSACTION_CREATED	transaksi	76f355f4-7b86-4b0d-aa8d-aa1b3bac6e09	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-24 07:59:02.388194	{"total_harga": 3000, "id_transaksi": "76f355f4-7b86-4b0d-aa8d-aa1b3bac6e09", "kode_transaksi": "TRX-AC6E09", "tipe_pelanggan": "guest"}
bb28205f-5de6-4c13-94eb-0282332cbb76	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-DB4B55 sebesar Rp2.000 atas nama "guest-DB4B55".	TRANSACTION_CREATED	transaksi	a2b62f0e-9095-4874-bd31-aeb9ebdb4b55	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-24 07:59:33.047705	{"total_harga": 2000, "id_transaksi": "a2b62f0e-9095-4874-bd31-aeb9ebdb4b55", "kode_transaksi": "TRX-DB4B55", "tipe_pelanggan": "guest"}
c436c6ce-ebff-4a4b-96ac-94214413e0b1	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-18E12D sebesar Rp1.500 atas nama "guest-18E12D".	TRANSACTION_CREATED	transaksi	bea35d51-0ea1-475d-b7d9-5b269718e12d	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-24 08:04:31.420695	{"total_harga": 1500, "id_transaksi": "bea35d51-0ea1-475d-b7d9-5b269718e12d", "kode_transaksi": "TRX-18E12D", "tipe_pelanggan": "guest"}
4bde5e61-0fd9-45c3-803b-1131ee8f37d6	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-D5D8D1 sebesar Rp3.000 atas nama "guest-D5D8D1".	TRANSACTION_CREATED	transaksi	57de1ae1-7e24-44cf-83b0-1516acd5d8d1	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-24 08:06:25.756066	{"total_harga": 3000, "id_transaksi": "57de1ae1-7e24-44cf-83b0-1516acd5d8d1", "kode_transaksi": "TRX-D5D8D1", "tipe_pelanggan": "guest"}
253e8819-d1ce-4e53-85de-bd4b7ecadeb7	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-79F030 sebesar Rp2.500 atas nama "guest-79F030".	TRANSACTION_CREATED	transaksi	2e86384d-3004-4cd2-9f35-a7b21979f030	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 08:07:45.006333	{"total_harga": 2500, "id_transaksi": "2e86384d-3004-4cd2-9f35-a7b21979f030", "kode_transaksi": "TRX-79F030", "tipe_pelanggan": "guest"}
438f8da9-8213-4255-8f61-8a897dae2081	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-F72E08 sebesar Rp14.000 atas nama "guest-F72E08".	TRANSACTION_CREATED	transaksi	e75b13b5-e746-4933-b108-ea9c29f72e08	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 08:08:44.119774	{"total_harga": 14000, "id_transaksi": "e75b13b5-e746-4933-b108-ea9c29f72e08", "kode_transaksi": "TRX-F72E08", "tipe_pelanggan": "guest"}
77588dcc-3051-4208-8157-eccc1c56ee3f	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-4E6D86 sebesar Rp3.500 atas nama "guest-4E6D86".	TRANSACTION_CREATED	transaksi	84f90a4f-f2f3-448b-9d15-56720e4e6d86	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-24 08:09:29.31884	{"total_harga": 3500, "id_transaksi": "84f90a4f-f2f3-448b-9d15-56720e4e6d86", "kode_transaksi": "TRX-4E6D86", "tipe_pelanggan": "guest"}
6d899dc5-1345-49ea-b1d5-a4109365f395	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-003757 sebesar Rp3.500 atas nama "guest-003757".	TRANSACTION_CREATED	transaksi	99c8a56e-a1a2-4787-b396-997b9f003757	81caf204-9368-484b-b200-f9d4bde5c87b	f	2026-09-24 08:18:46.701484	{"total_harga": 3500, "id_transaksi": "99c8a56e-a1a2-4787-b396-997b9f003757", "kode_transaksi": "TRX-003757", "tipe_pelanggan": "guest"}
6b67a2f8-b9e5-4b34-9a87-4f603b654675	Laporan Harian Toko	Laporan harian 2026-09-24: total penjualan Rp 146.000 dari 16 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-09-24 14:00:00.090308	{"summary": {"total_sales": 146000, "total_transactions": 16, "total_guest_transactions": 12, "total_member_transactions": 4}, "daily_items": [{"quantity": 1000, "subtotal": 14000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "3bde8355-7418-4abf-9a40-0d615f5c7e99"}, {"quantity": 1, "subtotal": 3500, "item_name": "Indomie Goreng", "id_transaksi": "baf7b66b-bfd6-4285-9790-63d446bf965d", "customer_name": "guest-BF965D", "customer_type": "guest", "kode_transaksi": "TRX-BF965D", "id_detail_transaksi": "ef7ffcee-21cf-4ccf-9639-14e9f9f952b6"}, {"quantity": 1500, "subtotal": 21000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C", "id_detail_transaksi": "aef41aa8-c8dc-42d7-90dc-626310801b1b"}, {"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "68718128-2a4f-43c6-967d-ef76d33a0fd3", "customer_name": "pelanggan6", "customer_type": "member", "kode_transaksi": "TRX-3A0FD3", "id_detail_transaksi": "062ce7bd-1d2c-4c54-a8fe-270e4845e4ee"}, {"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "5e15ecd6-71f7-4081-85df-87df98168335", "customer_name": "guest-168335", "customer_type": "guest", "kode_transaksi": "TRX-168335", "id_detail_transaksi": "803f5ff6-081c-4107-a746-7a5fb2b4f436"}, {"quantity": 1000, "subtotal": 5000, "item_name": "Dedak", "id_transaksi": "3e3e6625-beb5-446d-8909-130dcbc47275", "customer_name": "pelanggan7", "customer_type": "member", "kode_transaksi": "TRX-C47275", "id_detail_transaksi": "a55c21f5-df02-4976-9ada-0b112ae5d31c"}, {"quantity": 1, "subtotal": 18000, "item_name": "Sunco 1 L", "id_transaksi": "d7993f5e-40f8-411f-9704-eadd7eb8cb8b", "customer_name": "guest-B8CB8B", "customer_type": "guest", "kode_transaksi": "TRX-B8CB8B", "id_detail_transaksi": "6a3486b4-e6f6-44c5-afed-39be3ff60410"}, {"quantity": 1500, "subtotal": 21000, "item_name": "Beras Cap Raja Lele", "id_transaksi": "1a492d49-b2bf-4541-a3d8-1425b4e5f935", "customer_name": "pelanggan8", "customer_type": "member", "kode_transaksi": "TRX-E5F935", "id_detail_transaksi": "bdd19fae-3dcf-4c39-827a-051d01feb047"}, {"quantity": 500, "subtotal": 2500, "item_name": "Dedak", "id_transaksi": "bd3f581c-5e74-485e-8501-b95707c9eedc", "customer_name": "guest-C9EEDC", "customer_type": "guest", "kode_transaksi": "TRX-C9EEDC", "id_detail_transaksi": "6eb613a7-8ff9-4d6d-9320-36ed29628584"}, {"quantity": 1, "subtotal": 3000, "item_name": "Good Day Cappuccino 25gr", "id_transaksi": "76f355f4-7b86-4b0d-aa8d-aa1b3bac6e09", "customer_name": "guest-AC6E09", "customer_type": "guest", "kode_transaksi": "TRX-AC6E09", "id_detail_transaksi": "e32e9816-89ba-4098-b089-62dd79405851"}, {"quantity": 2, "subtotal": 2000, "item_name": "Kopi Luwak Hitam", "id_transaksi": "a2b62f0e-9095-4874-bd31-aeb9ebdb4b55", "customer_name": "guest-DB4B55", "customer_type": "guest", "kode_transaksi": "TRX-DB4B55", "id_detail_transaksi": "0de89bfb-1fd0-44f5-893a-deedca6576a5"}, {"quantity": 30, "subtotal": 1500, "item_name": "Bawang Putih", "id_transaksi": "bea35d51-0ea1-475d-b7d9-5b269718e12d", "customer_name": "guest-18E12D", "customer_type": "guest", "kode_transaksi": "TRX-18E12D", "id_detail_transaksi": "63e92b49-0710-43fd-99b2-4abdcd891c71"}, {"quantity": 30, "subtotal": 3000, "item_name": "Cabai Rawit", "id_transaksi": "57de1ae1-7e24-44cf-83b0-1516acd5d8d1", "customer_name": "guest-D5D8D1", "customer_type": "guest", "kode_transaksi": "TRX-D5D8D1", "id_detail_transaksi": "d437e424-2381-4460-9a3c-9cac0b3ddf82"}, {"quantity": 30, "subtotal": 2500, "item_name": "Cabai Merah Keriting", "id_transaksi": "2e86384d-3004-4cd2-9f35-a7b21979f030", "customer_name": "guest-79F030", "customer_type": "guest", "kode_transaksi": "TRX-79F030", "id_detail_transaksi": "8ca96f1b-6904-4200-a69c-a81d7f67b361"}, {"quantity": 1000, "subtotal": 14000, "item_name": "Beras Parimas", "id_transaksi": "e75b13b5-e746-4933-b108-ea9c29f72e08", "customer_name": "guest-F72E08", "customer_type": "guest", "kode_transaksi": "TRX-F72E08", "id_detail_transaksi": "ec13301b-a320-42c3-b0d5-39a40cf2ebfc"}, {"quantity": 1, "subtotal": 3500, "item_name": "Mie Sedap Goreng", "id_transaksi": "84f90a4f-f2f3-448b-9d15-56720e4e6d86", "customer_name": "guest-4E6D86", "customer_type": "guest", "kode_transaksi": "TRX-4E6D86", "id_detail_transaksi": "6473dc44-3274-4860-b48a-b36ad1d76d49"}, {"quantity": 1, "subtotal": 3500, "item_name": "Indomie Goreng", "id_transaksi": "99c8a56e-a1a2-4787-b396-997b9f003757", "customer_name": "guest-003757", "customer_type": "guest", "kode_transaksi": "TRX-003757", "id_detail_transaksi": "46c48ec7-6006-48d7-b01a-460bb496c0bf"}], "report_date": "2026-09-24", "generated_at": "2026-09-24T14:00:00.084Z", "highest_transaction": {"total_harga": 21000, "id_transaksi": "f6c2d69d-b6b6-4429-a426-7ef43ecf468c", "customer_name": "pelanggan5", "customer_type": "member", "kode_transaksi": "TRX-CF468C"}}
982d2d73-47f4-474b-ac2e-67498bf0125c	Laporan Harian Toko	Laporan harian 2026-09-25: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	f	2026-09-25 14:00:00.244321	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-09-25", "generated_at": "2026-09-25T14:00:00.232Z", "highest_transaction": null}
93fab40b-c162-452c-b22d-aa381d6445aa	Laporan Harian Toko	Laporan harian 2026-09-26: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-09-26 14:00:00.285369	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-09-26", "generated_at": "2026-09-26T14:00:00.252Z", "highest_transaction": null}
df851f02-7def-4b89-8e40-ae92163c70f2	Laporan Harian Toko	Laporan harian 2026-09-27: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-09-27 14:00:00.183084	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-09-27", "generated_at": "2026-09-27T14:00:00.178Z", "highest_transaction": null}
0e8be143-3698-48e2-8c67-654ede63821d	Laporan Harian Toko	Laporan harian 2026-09-28: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	f	2026-09-28 14:00:00.148697	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-09-28", "generated_at": "2026-09-28T14:00:00.135Z", "highest_transaction": null}
35b07471-5125-4649-ab7c-d45b5d5e7d71	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-3FE84B sebesar Rp17.500 atas nama "guest-3FE84B".	TRANSACTION_CREATED	transaksi	635a7da3-f04b-4b76-b5c5-f32b103fe84b	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-22 14:21:06.32029	{"total_harga": 17500, "id_transaksi": "635a7da3-f04b-4b76-b5c5-f32b103fe84b", "kode_transaksi": "TRX-3FE84B", "tipe_pelanggan": "guest"}
c52f1f84-e4d5-4b27-a98b-f558f11b41b7	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:09:40.022603	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:09:40.021Z", "highest_transaction": null}
e0130a1c-7f3d-47f5-b968-e544f509c946	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:09:50.01406	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:09:50.013Z", "highest_transaction": null}
ef85897b-4e11-4c86-a8a5-1fbd86a3b0ba	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:09:55.018673	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:09:55.018Z", "highest_transaction": null}
11e12c90-a4ec-41d6-8688-517ce01aa4cc	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:10:05.006109	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:10:05.005Z", "highest_transaction": null}
2ca36f96-225d-4dc8-8d95-f87135e791f9	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:11:20.022948	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:11:20.022Z", "highest_transaction": null}
5426710f-30b3-4922-8578-85aeaab04742	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:11:25.017363	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:11:25.016Z", "highest_transaction": null}
9ca3d263-4518-47bf-8e87-c31d561f5383	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-5F3C5D sebesar Rp6.000 atas nama "guest-5F3C5D".	TRANSACTION_CREATED	transaksi	cb04caad-817a-4ff5-9d8d-6a1da25f3c5d	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-13 09:42:17.789996	{"total_harga": 6000, "id_transaksi": "cb04caad-817a-4ff5-9d8d-6a1da25f3c5d", "kode_transaksi": "TRX-5F3C5D", "tipe_pelanggan": "guest"}
2b4ccc52-3d54-484b-91cb-c078215666fc	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:09:45.013057	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:09:45.012Z", "highest_transaction": null}
cc5269ab-00ce-45f3-9f75-33b976f43368	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:10:00.005104	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:10:00.004Z", "highest_transaction": null}
55a504f0-9160-48ec-9756-d9948f452b2f	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:10:10.007877	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:10:10.007Z", "highest_transaction": null}
27201e64-a290-48e9-aac9-2d6e71d249be	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:11:15.106462	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:11:15.099Z", "highest_transaction": null}
71ea48e2-e7d8-4929-90fe-87f427d2a30b	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 11:11:30.016471	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T04:11:30.015Z", "highest_transaction": null}
e9e2a5c8-9fed-4ca6-805c-81ecacf919f6	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:17:25.099626	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:17:25.079Z", "highest_transaction": null}
c97ec549-008f-4af2-b5e9-7781de950f8c	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:17:30.013044	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:17:30.011Z", "highest_transaction": null}
1e549665-cf36-4f11-97a5-06d9b69f0d6e	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:17:35.017468	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:17:35.016Z", "highest_transaction": null}
8ef5dbb3-aade-4598-afb4-0444b585b45a	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:17:40.011814	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:17:40.010Z", "highest_transaction": null}
ec990664-40c4-4929-af2b-737632a08ea5	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:17:45.00465	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:17:45.003Z", "highest_transaction": null}
c6d91c9a-f0e5-4b37-bcef-1d5336c7f201	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:17:50.008759	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:17:50.007Z", "highest_transaction": null}
eff103e3-bd32-4294-9fba-f5865310f22a	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:17:55.012046	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:17:55.011Z", "highest_transaction": null}
aa937834-6af8-45c6-b543-a6259ed0e7bf	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:18:00.017758	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:18:00.016Z", "highest_transaction": null}
672639ad-a154-4dfd-8c1f-bbc6a0a99993	Laporan Harian Toko	Laporan harian 2026-08-04: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-04 13:18:05.012178	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-04", "generated_at": "2026-08-04T06:18:05.011Z", "highest_transaction": null}
35b43714-ca22-477a-8b87-6117d670454f	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:00.084324	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:00.077Z", "highest_transaction": null}
1fd5c960-61b8-4f4a-ad1b-0649ae854ee3	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:05.012993	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:05.011Z", "highest_transaction": null}
2610c895-8460-4b32-8c66-9ae8a2da2d5b	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:10.019028	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:10.017Z", "highest_transaction": null}
79de1272-4960-4486-ad73-2cbb8e503e7c	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:15.012642	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:15.011Z", "highest_transaction": null}
58cb917f-a1b8-4658-bd3a-a16b41546e83	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:20.013178	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:20.011Z", "highest_transaction": null}
2e62f60e-9a81-4238-a9b9-ca3b7e58ccb3	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:25.004964	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:25.003Z", "highest_transaction": null}
d3535573-66f9-4935-b5cb-45069a6edb4e	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:30.012748	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:30.011Z", "highest_transaction": null}
0b2369eb-84be-4e55-a6fc-3564c2154f99	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:40.005255	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:40.003Z", "highest_transaction": null}
ab66aff4-a07c-4751-bf45-a0d5b28740cd	Laporan Harian Toko	Laporan harian 2026-08-14: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-14 13:11:35.013852	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-14", "generated_at": "2026-08-14T06:11:35.012Z", "highest_transaction": null}
143e4f17-c137-49c1-9d4f-a36979220bcb	Laporan Harian Toko	Laporan harian 2026-08-19: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-19 21:00:15.110949	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-19", "generated_at": "2026-08-19T14:00:15.103Z", "highest_transaction": null}
94f96207-9c73-4d74-88f2-85fc2e6ca1f2	Laporan Harian Toko	Laporan harian 2026-08-19: total penjualan Rp 0 dari 0 transaksi.	REPORT_DAILY	\N	\N	\N	t	2026-08-19 21:00:20.021954	{"summary": {"total_sales": 0, "total_transactions": 0, "total_guest_transactions": 0, "total_member_transactions": 0}, "daily_items": [], "report_date": "2026-08-19", "generated_at": "2026-08-19T14:00:20.019Z", "highest_transaction": null}
edcdd383-c7ec-4dc9-8119-1f09c52bb13a	Transaksi Baru Dibuat	Kasir kasir1 membuat transaksi TRX-FC5E83 sebesar Rp5.000 atas nama "guest-FC5E83".	TRANSACTION_CREATED	transaksi	d4921c24-9f9b-4869-aa69-965e26fc5e83	81caf204-9368-484b-b200-f9d4bde5c87b	t	2026-09-22 14:22:52.580088	{"total_harga": 5000, "id_transaksi": "d4921c24-9f9b-4869-aa69-965e26fc5e83", "kode_transaksi": "TRX-FC5E83", "tipe_pelanggan": "guest"}
\.


--
-- Data for Name: pelanggan; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pelanggan (id_pelanggan, nama_pelanggan, no_hp, poin_loyalitas, total_pembelian, frekuensi_transaksi, created_at, updated_at) FROM stdin;
afefb89d-9d30-4d58-bf3d-cf97053cd711	pelanggan2	081256768764	9	100000	3	2025-06-27 05:13:10.154424	2026-04-18 20:36:00.165006
5adb3c6c-7aad-484f-8509-52f420932591	pelanggan1	081398728872	7	113000	8	2025-06-27 05:12:45.021943	2026-05-07 15:45:58.345197
e17eb15d-10fc-43b7-8c8c-55088b7e2547	pelanggan3	085798686543	7	92000	3	2026-01-08 13:40:14.503236	2026-05-07 15:50:56.242937
19ec6aa0-28df-4b03-92ba-418d1cc86953	pelanggan4	\N	4	74500	9	2026-01-08 13:41:55.191617	2026-07-26 19:51:45.527058
ffd18fbb-3d37-462e-9db5-a27ffbd7bc52	pelanggan5	\N	3	31500	2	2026-05-07 15:54:42.42597	2026-09-24 03:01:40.020623
e0ccc529-7a26-4fa7-a0e2-cd2da51a09c7	pelanggan6	\N	1	14000	1	2026-05-07 18:29:34.39002	2026-09-24 03:19:40.429358
e2c0e616-6a40-4dbf-98e1-d3275d407ce9	pelanggan7	\N	0	5000	1	2026-05-07 18:46:01.801098	2026-09-24 07:50:56.237191
35d22c85-d308-41ee-8154-616c7e75508c	pelanggan8	\N	2	21000	1	2026-05-08 08:29:00.084424	2026-09-24 07:57:24.838633
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
0ddddf5c-209e-4428-9d43-8c9bb3864db9	TRX-864DB9	\N	guest	guest-864DB9	81caf204-9368-484b-b200-f9d4bde5c87b	14000	20000	6000	berhasil	2026-07-24 11:06:04.74175	2026-07-24 11:06:04.74175
3def66d0-31e5-43df-9eb1-9e8a7ab8cd5a	TRX-B8CD5A	\N	guest	guest-B8CD5A	81caf204-9368-484b-b200-f9d4bde5c87b	14000	50000	36000	berhasil	2026-07-26 17:04:43.751918	2026-07-26 17:04:43.751918
26e33d69-6fb5-493c-a616-01df636d2914	TRX-6D2914	\N	guest	guest-6D2914	81caf204-9368-484b-b200-f9d4bde5c87b	7000	10000	3000	berhasil	2026-07-26 17:14:26.597714	2026-07-26 17:14:26.597714
33502004-9e0f-4fa0-bad2-53b7ed424d02	TRX-424D02	ffd18fbb-3d37-462e-9db5-a27ffbd7bc52	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	10500	11000	500	berhasil	2026-07-26 19:53:20.655787	2026-07-26 19:53:20.655787
0ab50f49-8898-48fb-abe0-3c76afeeb8b3	TRX-EEB8B3	\N	guest	guest-EEB8B3	81caf204-9368-484b-b200-f9d4bde5c87b	28000	30000	2000	berhasil	2026-07-26 19:55:29.590526	2026-07-26 19:55:29.590526
cb04caad-817a-4ff5-9d8d-6a1da25f3c5d	TRX-5F3C5D	\N	guest	guest-5F3C5D	81caf204-9368-484b-b200-f9d4bde5c87b	6000	10000	4000	berhasil	2026-09-13 09:42:17.676086	2026-09-13 09:42:17.676086
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
635a7da3-f04b-4b76-b5c5-f32b103fe84b	TRX-3FE84B	\N	guest	guest-3FE84B	81caf204-9368-484b-b200-f9d4bde5c87b	17500	20000	2500	berhasil	2026-09-22 14:21:06.285058	2026-09-22 14:21:06.285058
d4921c24-9f9b-4869-aa69-965e26fc5e83	TRX-FC5E83	\N	guest	guest-FC5E83	81caf204-9368-484b-b200-f9d4bde5c87b	5000	10000	5000	berhasil	2026-09-22 14:22:52.568676	2026-09-22 14:22:52.568676
baf7b66b-bfd6-4285-9790-63d446bf965d	TRX-BF965D	\N	guest	guest-BF965D	81caf204-9368-484b-b200-f9d4bde5c87b	17500	20000	2500	berhasil	2026-09-24 01:30:38.19539	2026-09-24 01:30:38.19539
f6c2d69d-b6b6-4429-a426-7ef43ecf468c	TRX-CF468C	ffd18fbb-3d37-462e-9db5-a27ffbd7bc52	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	21000	25000	4000	berhasil	2026-09-24 03:01:40.020623	2026-09-24 03:01:40.020623
68718128-2a4f-43c6-967d-ef76d33a0fd3	TRX-3A0FD3	e0ccc529-7a26-4fa7-a0e2-cd2da51a09c7	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	14000	20000	6000	berhasil	2026-09-24 03:19:40.429358	2026-09-24 03:19:40.429358
5e15ecd6-71f7-4081-85df-87df98168335	TRX-168335	\N	guest	guest-168335	81caf204-9368-484b-b200-f9d4bde5c87b	14000	14000	0	berhasil	2026-09-24 07:49:31.548003	2026-09-24 07:49:31.548003
3e3e6625-beb5-446d-8909-130dcbc47275	TRX-C47275	e2c0e616-6a40-4dbf-98e1-d3275d407ce9	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	5000	5000	0	berhasil	2026-09-24 07:50:56.237191	2026-09-24 07:50:56.237191
d7993f5e-40f8-411f-9704-eadd7eb8cb8b	TRX-B8CB8B	\N	guest	guest-B8CB8B	81caf204-9368-484b-b200-f9d4bde5c87b	18000	20000	2000	berhasil	2026-09-24 07:51:59.352706	2026-09-24 07:51:59.352706
1a492d49-b2bf-4541-a3d8-1425b4e5f935	TRX-E5F935	35d22c85-d308-41ee-8154-616c7e75508c	member	\N	81caf204-9368-484b-b200-f9d4bde5c87b	21000	21000	0	berhasil	2026-09-24 07:57:24.838633	2026-09-24 07:57:24.838633
bd3f581c-5e74-485e-8501-b95707c9eedc	TRX-C9EEDC	\N	guest	guest-C9EEDC	81caf204-9368-484b-b200-f9d4bde5c87b	2500	2500	0	berhasil	2026-09-24 07:58:22.847907	2026-09-24 07:58:22.847907
76f355f4-7b86-4b0d-aa8d-aa1b3bac6e09	TRX-AC6E09	\N	guest	guest-AC6E09	81caf204-9368-484b-b200-f9d4bde5c87b	3000	3000	0	berhasil	2026-09-24 07:59:02.359846	2026-09-24 07:59:02.359846
a2b62f0e-9095-4874-bd31-aeb9ebdb4b55	TRX-DB4B55	\N	guest	guest-DB4B55	81caf204-9368-484b-b200-f9d4bde5c87b	2000	2000	0	berhasil	2026-09-24 07:59:33.022194	2026-09-24 07:59:33.022194
bea35d51-0ea1-475d-b7d9-5b269718e12d	TRX-18E12D	\N	guest	guest-18E12D	81caf204-9368-484b-b200-f9d4bde5c87b	1500	2000	500	berhasil	2026-09-24 08:04:31.38555	2026-09-24 08:04:31.38555
57de1ae1-7e24-44cf-83b0-1516acd5d8d1	TRX-D5D8D1	\N	guest	guest-D5D8D1	81caf204-9368-484b-b200-f9d4bde5c87b	3000	5000	2000	berhasil	2026-09-24 08:06:25.732349	2026-09-24 08:06:25.732349
2e86384d-3004-4cd2-9f35-a7b21979f030	TRX-79F030	\N	guest	guest-79F030	81caf204-9368-484b-b200-f9d4bde5c87b	2500	3000	500	berhasil	2026-09-24 08:07:44.981594	2026-09-24 08:07:44.981594
e75b13b5-e746-4933-b108-ea9c29f72e08	TRX-F72E08	\N	guest	guest-F72E08	81caf204-9368-484b-b200-f9d4bde5c87b	14000	14000	0	berhasil	2026-09-24 08:08:44.092377	2026-09-24 08:08:44.092377
84f90a4f-f2f3-448b-9d15-56720e4e6d86	TRX-4E6D86	\N	guest	guest-4E6D86	81caf204-9368-484b-b200-f9d4bde5c87b	3500	5000	1500	berhasil	2026-09-24 08:09:29.286023	2026-09-24 08:09:29.286023
99c8a56e-a1a2-4787-b396-997b9f003757	TRX-003757	\N	guest	guest-003757	81caf204-9368-484b-b200-f9d4bde5c87b	3500	5000	1500	berhasil	2026-09-24 08:18:46.677406	2026-09-24 08:18:46.677406
\.


--
-- Data for Name: user_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_sessions (session_id, user_id, refresh_hash, user_agent, ip_address, created_at, expires_at, revoked_at) FROM stdin;
7fa3086a-2a9a-4d96-8716-58e160b0794e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$4KMZC6iqCRMFzEPO4kVqauT9ibinPrmUVoTRIjSvmetrHLG.OMWgK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-24 11:03:04.812901	2026-07-24 12:06:31.349	2026-08-01 17:33:44.104589
81af48c5-226f-45cc-962e-349be2446e41	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$iEw3d8u4FQtXWauQi4Hj2eyNOXQm.xwr8JhSxE6SegibGR/Ch5JZG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::ffff:192.168.1.3	2026-08-01 16:04:30.67104	2026-08-01 18:33:43.338	2026-08-01 17:33:44.104589
3bb88ca1-a7a7-4459-9595-9d903a63a71d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$g0F4CpnmURNsDOVgO1zjq.0HyeC042spiezoCbEeSg1vAbzZvxdQ.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-26 16:29:51.085042	2026-07-26 18:53:37.535	2026-08-01 17:33:44.104589
d3321ac9-dc75-4b68-930b-156f57c82084	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$2OoCEYA3xu1VN8jupevF3e9YrfHNQyxKVDgBegqTSplaJwHUuzsem	PostmanRuntime/7.54.0	::1	2026-07-14 16:59:54.517801	2026-07-14 17:59:54.117	2026-08-01 17:33:44.104589
df53cd6a-3598-4183-abe1-5764eec63e78	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$aUNisProiovAwdcPMYiKSOZudq0NC9WzyDQvASDZi8tQldcwDed8G	PostmanRuntime/7.54.0	::1	2026-07-15 12:47:39.943394	2026-07-15 13:51:47.808	2026-08-01 17:33:44.104589
0e60858a-a248-4d1e-980c-ee068fa3e517	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$MmAUfaiI8Zz1Vp9OHrA/g.VKo2U3OvHG/oQ5Db.LhUDnaB1P32Dhe	PostmanRuntime/7.54.0	::1	2026-07-19 15:59:33.684628	2026-07-19 17:02:47.441	2026-08-01 17:33:44.104589
c345af35-2380-463c-8f60-7683b4e11818	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$AGvrrbtH8zVI2ivWQot/Hub9PVq8RlxxoqXddHJbs0iXnbHKKquvu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 11:18:12.776991	2026-05-08 12:27:07.991	2026-08-01 17:33:44.104589
cbe45231-0372-4650-8716-a0c9395b8954	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$toU7STJDbMTQo60hrOZiKep4sDu0O5FuqybnHQgB45TvMpzLmXAuS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 11:47:58.200795	2026-05-07 13:38:39.318	2026-08-01 17:33:44.104589
66befbdd-c551-4325-8f22-519a71d9b253	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$gQb2vCLny2ZpvqV7lpTN1OM5vLI0EcDpaTJEBlHcEqFrX1nDsXNZO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-26 19:26:43.14251	2026-07-26 21:28:14.055	2026-07-26 20:29:12.097132
0db28da2-579f-4b30-979f-f9c2be9a6e9e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$p0YtnHcSUn3XeyPLoEWg4ecUsCVE4y94PhBEnRp9TSvV8QrYgVYpO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-30 13:27:59.61389	2026-07-30 14:27:59.193	\N
010cab28-061d-4748-9e61-4b554baef35a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$hqz4a89OZK7PlrIrqng3LOSbwSX9GWMYs79c1mVWk0/oPlQCTYMQG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-30 13:28:05.172471	2026-07-30 14:28:04.787	\N
8248773d-0363-4e04-905b-1a0d18d8b71e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$hpFXpqTBgb2fv1MkhkIYjOFR.5A0iFtV8of20AiylMZ/JjOHexG96	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 13:39:14.196632	2026-05-07 16:40:22.818	2026-08-01 17:33:44.104589
56376fb5-05fa-4357-a38d-6320df049679	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$2ZCGc09ek64lWB0Yejbb4uyaoSe6C7tZMzWEQZN1VYiwEQbx0HoNC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 11:24:22.224017	2026-05-10 12:24:21.935	2026-08-01 17:33:44.104589
37cb5d6c-9330-4ed8-b88d-7def98937165	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$BzzntXvni6ZbmchnthDfLeWgpYKX5Yp/ZRyLGcq.E1sJHyKbucTsa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 08:29:36.515181	2026-05-08 10:49:10.496	2026-08-01 17:33:44.104589
49a2f8e7-228c-4644-8c11-eb618c601026	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$StYFdLhJeg1.6UxPbx00jelRmfWSnRsuJ7E0qm8SKQqEo/Q/65fKq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::ffff:10.69.13.99	2026-07-30 13:32:05.215349	2026-07-30 15:01:30.863	2026-07-30 14:02:53.121449
3a1e9fe5-f609-4102-9deb-de8e6ae996a1	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$sJVsMGX/UMhF9MZzARB3I.oAR5sHibtprmMx58g3d.kmxCA.b3axC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 12:23:05.012551	2026-05-10 13:23:04.629	2026-08-01 17:33:44.104589
108ca7c6-1bf2-49e1-9d96-d6b4a06a8a01	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$IUn35/blso5ILkerWeWGXe9krVmrC4KRU2C3afsC696rVS95XaKTC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-15 12:53:48.884353	2026-07-15 13:53:48.492	2026-08-01 17:33:44.104589
6da83a0c-25f4-44d1-b65c-251d35057895	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$AU9mqtpK8THl60H1Ikc50Odokvru0v94kmHBZSwaYwz0FypYcZ/U6	PostmanRuntime/7.54.0	::1	2026-07-19 18:26:24.843014	2026-07-19 19:39:52.971	2026-08-01 17:33:44.104589
c3b673b7-3785-4c45-8bdf-a2f8e892460d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$H0V36dbB3EY0vovY4yG.huLdA/Q1gAcanc/kDcXE3kEDtp8YGrDIa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 22:51:14.218911	2026-05-13 01:03:14.327	2026-08-01 17:33:44.104589
cea3903c-b7b8-4204-b9da-f2a7019bf302	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$4KytYYrGXueHdZqdvOnAEuYGgUdxmdXBKXq24BbvyYIRVlkL6qd6i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 16:31:33.875436	2026-05-12 18:48:28.507	2026-08-01 17:33:44.104589
ad099426-93c2-4cf7-ae56-4bb7ec9231c1	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$sHT4r8AtT.U4DMvKcnmbm.E3aUrQNfL7cuERFJS0BG6RpiV0LiIUS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-20 00:08:47.251487	2026-07-20 01:56:31.435	2026-08-01 17:33:44.104589
6120d60b-2057-41ed-837f-841f965ad8e1	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$L6lYac0Jvuxta9RaL6uHDeXbfGojK.jC5pct.R8COSs5PUjLKsuBO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-23 12:42:28.333882	2026-07-23 14:41:16.91	2026-08-01 17:33:44.104589
d209cf3b-5805-4873-9f25-d482d8d6525c	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Xc/1lMvpNoms2r1nLtGwiehnItKa/iK1Z1B2yuC3sp/QPcgrj84Fi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-21 14:20:43.585822	2026-07-21 15:40:47.5	2026-08-01 17:33:44.104589
2c9b75ba-001b-4242-bfbb-d0a5e728522b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$a2cnMcogD1uLyD3oDX0OXOZSo/AFh8EMQnbK8WfFXVtKyYVExFbcy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 19:33:16.437641	2026-05-12 21:45:18.401	2026-08-01 17:33:44.104589
8f4344d1-b226-4d75-bbc5-8b97941c7c32	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$qkw8CtBu6XUtrJ4evZNh1O9HjnUjhfLJe15lHkI.8vmPztU79QMaG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-21 17:55:02.252797	2026-07-21 18:57:21.906	2026-08-01 17:33:44.104589
de19d255-0def-4570-b069-07f6a6c13f34	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$gH76.fFvzkr0Qq8LBD4gKOJzjMaz74CUfBJWnRM6rcjgbM.ZKDaBe	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.2	2026-08-04 11:14:00.721069	2026-08-04 12:14:00.34	2026-08-04 11:14:11.575096
c4f92efe-90ec-4956-bd8a-a3d359a35d29	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$B2eB3i2XjqOGVXmAUDpB.eRY6cA.QfwVzEhT6amqdQ4Ga7zTgXFxG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-24 11:03:23.580987	2026-07-24 12:06:04.33	2026-07-24 11:06:28.396272
ed335d32-291a-4e8f-bbb9-6ef9af1d6aa7	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$aX8GVWzU81Ba1nwFQ3HN9O9k6LbUZ0lcSL1ITxW75FdNN/ZGej0e2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-26 16:30:04.035337	2026-07-26 18:51:35.983	\N
a9a4225f-58fe-463e-9567-c5cee77b5718	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$oAZFQP0uuT/IuEN.I2Cpte2geUbWud0cTW/O4iha9fM781j4LE3hu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-26 19:48:54.34922	2026-07-26 21:28:13.546	2026-07-26 20:29:05.606426
d23d50fb-0c44-4d35-81a7-d0ea2215c89c	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$dagAE.WOBR5HXzImQmGAk.rgq.ooTqTixZX2l8ull60qgzPIsb1i6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-29 03:59:09.906536	2026-10-13 03:59:09.625	\N
21a039be-505b-4b89-ad75-70a6f12ce199	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Rpw1O.meSkK95uqpJiziNOfBcLUqOPCIh98NNIrfmET7BQXS8QD/i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::ffff:10.69.13.99	2026-07-30 13:30:54.219474	2026-07-30 15:01:25.234	2026-07-30 14:03:00.068982
037df162-57d6-4063-acea-61205d13cc91	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$C1.5TbWQtK7TAT8wcpx9ueRMG60vF0P6b3GFDv3L1IWK69jp0tu0G	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-08 16:46:30.021608	2026-08-08 17:46:29.644	2026-08-08 16:46:35.755515
619baebe-6c27-4da8-8300-af853acc0e2d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$3SzaguoTfdx15Z0uYGDFdeFImtO3GClPQjgOFQS.nceY99EdSEFqO	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:10.69.13.209	2026-07-30 13:33:25.390394	2026-07-30 14:35:50.058	2026-08-01 17:33:44.104589
e4119cf6-4ea1-4835-9db8-87054ec4ec78	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$2tlClnznZ9uTo7mOXx08E.jrZAQmGjMFpMykfS4fzr.ql3j5vFvlm	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.2	2026-08-01 16:05:53.673472	2026-08-01 18:05:32.126	2026-08-01 17:33:44.104589
3e817f9f-4763-4eb7-b527-e52e2a06a903	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$e4fPqYGd5vUVqRa/Pw6uqef6/vSypLg8HG02trcnHGzmnM9MF81FG	PostmanRuntime/7.53.0	::1	2026-07-10 15:44:03.744883	2026-07-10 16:44:03.348	2026-08-01 17:33:44.104589
9c3ca6a1-fa53-4ae4-8a71-89057c678376	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$NHhHKMI/Hoan9O/djKyw7eASC9HHqncRXOtoNNvgNEN7626Ok4udG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-20 15:01:44.668371	2026-07-20 19:18:56.266	2026-08-01 17:33:44.104589
0f8c7c43-68bb-4176-a223-cf72d46e4d8d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$sw4nizk9v1PeY.6owEIMGOcGMrOo.q1tHlBYvDH/cLuiZNpq9aK5K	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:10.69.13.209	2026-07-30 14:01:47.93093	2026-07-30 15:01:47.555	2026-08-01 17:33:44.104589
67218991-5c8d-4ca7-a860-f2f3315b8330	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$YrX6EA.GHEl2QeR/nh3CZ.9BCXraG4tHrCMKPiTaJDRw6gllH/jQG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-08 16:53:14.444653	2026-08-08 17:53:14.066	2026-08-08 16:53:22.426127
dc98c1ff-50cc-4150-a285-705f53e549a3	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$bEUpdPTbmGBpH2pBMCeZU.NqZlgsMvF.U4llroRlaTTW3HscOODAK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-09 19:46:48.867083	2026-08-09 20:46:48.49	\N
40c015c4-faf8-40f3-8d10-2b73ffa74f73	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$7xPXAkG4WLhVZrY4PeI4P.AFaj0m2as5RuESOgw.XGX64FVbHBeWC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-27 06:44:07.007503	2026-07-27 08:53:09.767	2026-07-27 07:53:20.128905
cb6887be-dc5e-420d-90e3-6eb118591973	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$SWFYPhxMtmbWZ1fcLnLV..sM/owemldIlNdkQ90f5Tl9c8gWe1IOG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::ffff:10.69.13.99	2026-07-30 13:31:00.064034	2026-07-30 14:30:59.682	\N
9b4cc27d-02ba-4807-9f3b-90812975f7da	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ssKSaoY6rCclimui10nV3OS/LR5RgbSYZ89bpLz/ho31SJYqKdfJ6	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:10.69.13.209	2026-07-30 13:36:13.08578	2026-07-30 14:36:12.701	2026-08-01 17:33:44.104589
616a513e-25a4-4652-8c81-76a649b9cf85	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$p4LKjvuIwBRvdj0vuMrZKevqqKkgk0pSf5FU2P7N0mRMTkNegmvz2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:00:49.344982	2026-05-04 12:00:48.972	2026-08-01 17:33:44.104589
23e2577e-4e1f-451d-9e7c-f086763abf09	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$OW0W2TzbqnJ2mT0zLlT30O2IKHviXQGqzjMKcVZs8.G160ZEwXU5q	PostmanRuntime/7.53.0	::1	2026-07-10 18:38:20.668493	2026-07-10 21:00:38.628	2026-08-01 17:33:44.104589
67da7f55-8738-48f1-8b71-93e36bae75c3	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$fJZERrc4Y6fjLzt8ElVx5./FwaFIbPXgLUFUQVxr.lC2h3VrOFzUG	PostmanRuntime/7.54.0	::1	2026-07-12 08:58:52.893736	2026-07-12 09:58:52.433	2026-08-01 17:33:44.104589
0c73c3de-d73e-4e59-aaec-a123b9e6df7e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$gr0vhM/5c3anlYslRKKkP.XczlC.RQLsOYqGAc.65TzDyhn/I1teu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 00:09:17.220967	2026-05-05 01:54:51.561	2026-08-01 17:33:44.104589
f33026b1-78b8-47a5-bae4-30d6f245e1b7	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$rSKoN4ETQHA865NalctK1On3wUH5lf1O3IOFiHtHKuvF3ZoOJf/T.	PostmanRuntime/7.54.0	::1	2026-07-11 06:44:02.269968	2026-07-11 07:47:19.058	2026-08-01 17:33:44.104589
95600764-a1be-4120-8380-987ef57542d8	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$NhJS6d6yz.M/FNSrSj58LOlHeELs18jWvl5XnOICIeCe7MzZnY73m	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:00:02.160746	2026-05-04 12:00:01.76	2026-05-04 11:00:40.540806
69b059b1-f43d-4e63-a3e3-382a7f26e4c7	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$jhsbjde1varZeQ2Fe7iOp.mrYX9l1noFggjC5CX93R8pEX0aPSfle	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 02:50:31.7851	2026-05-04 03:50:31.411	\N
44a6cdfd-99a5-4a63-a476-18b2fbacfb2b	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$8XU9bwZkNJUMZMHJGzNXVOc3DjWR7zuuklcWCX8FRDpNJwZiMkH0W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:07:11.430893	2026-05-04 12:13:33.431	2026-05-04 11:15:18.152844
2ff5cb79-316e-46d7-abeb-600506878815	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$9KiqkaqwuhXkYa2KxA5aT.gcf2kWgtLITEQ18LLvidEtgY4DpuAcS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-26 16:30:16.893137	2026-07-26 18:51:36.102	2026-09-24 04:21:46.660381
f6f9fa01-16fa-4e55-b46e-de07e58c245a	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$CbB7HEilJPNrOZNNAVDoq.vKZ2yX2r.6XPFBdgvfF6Uhsuo7JPe1i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 02:46:48.73172	2026-05-04 04:00:16.426	2026-09-24 04:21:46.660381
f70f4432-b897-4749-b7a8-504d312219ab	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$xIC2CF4m0DItncAAU4T1geP22BUclLfo6NhA5leUF9UbU8ujtmfF2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-03 18:16:40.886197	2026-05-03 20:33:40.148	2026-09-24 04:21:46.660381
6ba77738-4549-4b77-b144-29cd51a9567e	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$gpR.2y59cFz.2e0du/29Xu.1IHOwVtY8BqQLpkg7FDSgD0Vu.KqRm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 01:34:54.078829	2026-05-04 02:37:29.107	2026-09-24 04:21:46.660381
7219cb46-90bc-49e1-a052-ef723f1db245	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$m23h05I2S46yqgSSFewCnuk8CGLMKI.ciyL7Iu3IHco7A.kZCsJcS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 12:10:48.303167	2026-05-04 13:47:27.156	\N
02e89677-df9f-493f-a179-62ca00ae9e65	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$sbb5ua0/8j842T8mBMTrxOzUAdjWM/igfVYEGjA/335o6jfiM5W9.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 12:31:09.770024	2026-05-05 14:24:10.428	\N
9a545765-d46e-416f-9a61-1bbbc59dafb6	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$BQKSCQQ0S2W00RHEGWzBl.Q4un9jq8C/QCWyXTqqHLoH5ByFRaECa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 00:08:51.987913	2026-05-05 01:57:47.107	2026-05-05 00:57:50.102452
a80f76f7-a303-40a2-9ab9-5248a72dc0f3	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$HZjX7KdPxJ4QoE4zFzGCqeFTIHYAe4WwL/MFeVkZQuuht8ad9fwle	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 10:08:30.665037	2026-05-05 11:44:14.203	2026-05-05 10:45:44.295641
5f742356-4d06-475a-99a9-725395224cfe	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$DjPtOA.4aik69HOLt5xwP.tdjZdw6aEYVxGy.dNo97XCBZhiOBqQG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 11:11:50.874468	2026-05-05 12:14:26.844	2026-05-05 11:14:42.25048
b37a060e-f022-4f88-bc99-5b29f2501df4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Xomf3jR6YeMHUZzFaSPyhegVvuanB80gx79xpJztxaKDAs2yIfV8O	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 23:27:41.832159	2026-05-05 00:35:45.98	2026-05-04 23:36:02.072915
2651f4bf-a24d-4471-90b0-e1625e678aab	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$A3faFLoy2u7jze.WIu5.puN09ungWNaNVpWs6S.1izjANe2JC.6zG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 16:26:02.134507	2026-05-05 17:59:37.196	\N
dd84e4dc-ece5-40d7-b9d3-3cc202cc75bb	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$JiNO8XZvDCKe8xHyWlCBmu9f8H0H97lAx.JFgJ9rvK9taVle6ABx6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:18:20.72991	2026-05-07 09:18:20.279	\N
47dbd474-c6a8-4a03-9dc3-741400620a99	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$NlMlYqdZQZG2QyQ6g/YtYOjypNHZpgzOGnj3XlTs/E4ju3M5VBkH.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:48:28.80495	2026-05-07 10:09:17.127	\N
6bdcb884-6737-404b-aa6d-85fd1bbf6a24	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$o2F0gsbW9lGeXH1kBBdS0eAcMmmZ4soQJRGt8oAjpkzS4wn85ecJW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 11:47:40.946879	2026-05-07 16:40:19.218	\N
c7ba94a6-8a5a-49e3-9cda-4ac644736c2d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$buFekqcPxgTiis1DxkjmY.GOwvkCptN28pygm61ryC/cNdvX3GS5W	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 09:45:04.358675	2026-05-07 11:13:47.423	\N
27f810da-10ed-45d2-a71d-e1896cb5fb57	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$RHd9v90qilXGQjN6Ea09uuySyxZIUftSVpxeIze8BYIH..vxxQCjK	PostmanRuntime/7.54.0	::1	2026-07-19 23:04:58.21946	2026-07-20 00:23:15.863	2026-07-19 23:23:23.211315
5420e7e3-b4df-4224-aa53-4a737e2e261d	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$nl4DvS8QI3MzBp/gt6hQxu.XN7PfXhgJUQ.wre9qhfGikEbi8vILy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-20 01:07:02.846231	2026-07-20 02:07:02.459	2026-07-20 01:07:10.625952
c313c446-b892-42ef-9850-daca1ea73ee9	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Ugag2eovIihSIw4gV1CUoeKUqKe0AsWjCYnqMycVyksA/HTnfmJuG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 11:27:41.170673	2026-05-08 12:27:40.786	2026-05-08 11:29:05.195108
e51b919c-3ee0-48fd-a323-54b1e3bfa6ba	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$ByG3RYrNZjKVpFXBU9eyG.yLQxbyVfWk6Y28vGavl5XcJCoNQlbny	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 11:27:47.772761	2026-05-08 12:27:47.391	2026-05-08 11:29:06.899695
ac43dec5-251a-4606-9c6b-6d3da4dc3b62	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$93Wf8HFHIxJn8EFvV0a4D.eqJ.1PS1VFXLMRnAtNpXX.4iF1rUxrm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 22:52:26.893941	2026-05-10 00:57:42.118	\N
721570ab-c616-494d-aa1c-5ecdb2fe2122	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$ycHy9NGRzeFTvIN3qaAX1eElZo1hKvtUY1KCQxGuObAKd3poR7URS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 11:32:48.440041	2026-05-10 12:32:48.065	\N
e919c792-a9d7-43a4-a931-aae55f321dc2	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$eL230dccPl1frNzIIkM37.y6N.J/zmDMujvmbmmAi0KR5REU8mf.a	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 09:11:42.265289	2026-05-09 10:17:14.44	\N
13715f1d-c9db-458b-bda1-8d70bc2b4d26	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$tW5JadMnuxJMcDudpqUZ9OF.SDFTqNW/CuI6VdcHLfhMQ7fOz3mgK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 12:55:47.19596	2026-05-10 13:55:46.822	2026-05-10 12:56:11.146297
24f395d2-1ce7-493b-83cf-d5b8c927671b	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$msEvmopeC0.mcC8/DbrAzubd64ycOXogv/itT86kRKaEfVc8PfayS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 09:14:10.018287	2026-05-09 10:19:06.104	2026-05-09 09:19:21.654906
bf579ba1-f8ce-41cc-8aa4-e77930891e33	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$xKH68Hg8EIJGaVCKp.JF5OYUNIMC3bBRIiK0vI17HvZCtieeeBGS.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 18:37:02.132262	2026-05-09 19:37:01.737	\N
7226bcc8-25db-4f69-b038-93889b404cf2	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$rNOM2lzSjIoWU/RJ63w5IOjiumCkmsbwP7xQr/Kd7hYWgWu6Ai1na	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 09:10:01.903549	2026-05-10 10:51:57.336	2026-05-10 09:52:06.149586
d1155661-37aa-4b92-8f9c-fa6497dbae6e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Ny9634ovTHupuXh9zeG.fOm3uAjEEuFhyy0noFceKml6WPud4Q9Qu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 17:50:36.763843	2026-05-10 18:50:36.377	2026-05-10 17:50:38.968614
49dd1286-a566-4436-9bff-1725e34905ba	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$2cc997bsh8WFI/SFA6nYseTDMiCdIgkZyAm7oIqEI4ua3gLjaJYV2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 09:52:17.328906	2026-05-10 11:48:49.397	2026-05-10 10:50:34.488175
0dcb4fcb-e83e-4228-9f88-9432e0075c97	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$p5u4R.fNulsUZ59/oQ0WJ.4Ep.RJNadZdbr1mc6u0PLqnObzCn/Iu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 17:50:45.767843	2026-05-10 18:50:45.381	2026-05-10 17:50:48.492011
b10ae60a-4abf-4e75-af2b-225ddbec2062	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$Iwd5pPoQTPkFY8DvyV2P0eOzGV.ZG1yuVEI9coNsd.NxtqNt6RAfa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 17:59:09.467644	2026-05-10 20:21:26.491	\N
362d3fa7-a28d-412d-8f4f-83211f7a5dea	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$NbaDLclpqHdNH4FxdasWo./8Ao20iZgz/j7D.XzcZ5E3oWZZwKBQG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 23:36:49.792818	2026-05-11 00:57:26.169	\N
b1046ff7-8a90-4c0a-ac47-9ea0693edf49	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$vdekGZoCJyLhy6qAS/0gOeB1vWCS9oAg8B3fDSQ8fBoe7RJ2CRZwW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-11 11:21:39.161235	2026-05-11 12:26:52.037	2026-05-11 11:27:10.190979
839bad1b-633d-47e0-b7f9-68b1e31c1812	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$dE8F5jMLtAEORHFkFJpOFeP2JSiGZ1RX28eR4IsuAlceD4DeOggRO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-11 11:23:39.805323	2026-05-11 12:26:17.683	2026-05-11 11:26:47.451221
176a99ec-6fbe-4688-9e13-9dc7b1145984	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$YXmNrFp5A3/YRySxovwaW.f5HKWimf5uSmx/mV9taPq1S3bpmt6Ia	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-21 13:01:48.599233	2026-07-21 14:01:48.222	2026-07-21 13:02:43.023226
466870b6-b7c5-42f4-8e85-b777d6883fa7	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$IceAUURs0VIX5yKbzQsVueAO7F/5CQSIsvBvDijJKmnbpt/UWc1ga	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-21 13:02:49.212717	2026-07-21 14:02:48.834	2026-07-21 13:03:53.709862
69f2c06d-dd3a-43ff-b4a7-c32eb09ed5bf	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$wjko2xN7W3Pox.3KH7h/LOVr9nGerTYmFZI7/qRjbXqek3CXfLzcu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 22:51:05.608038	2026-05-13 01:03:13.379	\N
c6b3a15a-35b2-44dd-a5ab-7389fb52b07e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$b7CycVx2pSPhniEHvbQDBOc6xoNSxEkEHs9KHcZAVN4eLmQ2C7xrG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 07:47:42.99963	2026-05-13 08:47:42.622	\N
f52ad36f-f257-4174-949b-91f3a601d736	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$sB.Aw35Y9cZpisRe.IpffecjKIjlNkaJy.YRTUPmfv42TP/J8OXaG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 16:31:18.37053	2026-05-12 18:49:05.153	\N
9ff64714-f9a8-4bf1-b704-04dedb2dc04a	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$o8AaiWb29GoW4dsbb8HOaOLHL0BPQcyNow.4Hbm1dimeCEI9xS3F6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-21 13:05:34.232137	2026-07-21 14:05:33.851	2026-07-21 13:05:47.410382
5b75fd6d-7cfb-42ce-a051-f5a20454e20e	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$zUIvh06aH0hfkkcXpalcHO9Ha1oWwsxSRV7/JYfTQOhWSymkqkPK2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-12 19:33:26.592281	2026-05-12 21:42:38.961	\N
81f91f98-5516-4443-9ea7-1fe3f035af5a	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$yOcG662jAwmO50V4lg1RdOOSloKa3GuVXmpLLsic6KkDyUQZMflDG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-23 13:35:32.440806	2026-07-23 14:35:32.062	2026-07-23 13:35:38.386278
360b4800-5f23-4ce0-a5d7-f99b19dd76c8	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$uiw/5cYn7CRxUSX37cXIZ.yhDaYjoY9sbQducGlliCegn.c6FqIP.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-21 13:01:08.208643	2026-07-21 14:01:07.831	2026-07-21 13:01:43.619304
6f1a469b-1409-4058-9d17-5dbccd8481ec	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$nWEekYQrVF2OQFhKrIA4p.aqiGkIhL2a5Ta9BFB/97X2QXSRIbj7u	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-23 13:40:59.941317	2026-07-23 14:40:59.561	2026-07-23 13:41:39.813645
7086aeb7-b4fa-4de7-8d8b-112ab62bae89	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$2/ZTDAS6TEy2swqencUAr.FhRf0Lt19t8IHO9D3cpBKMSdRyI80Fy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-23 13:35:23.3723	2026-07-23 14:35:22.992	2026-07-23 13:35:41.138248
9fe9ff6a-537b-428b-933b-937461b73eb4	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$.OMRFEXNqSfKAlxhyT9Q4uP8l01jSpbrUCKVFFSZAiTWJGkjEfbCK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-23 13:40:03.0733	2026-07-23 14:40:02.69	2026-07-23 13:40:09.295547
6b3bc77f-7c60-4c00-b543-8ceb1cdaf279	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$AcAUGNtcxPBqDCOwHyjhE.GVNQn20NR09RB99dX8Lh7i8apgWLE.2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-26 19:33:45.36709	2026-07-26 21:28:13.639	2026-07-26 20:29:08.339985
3776c6bf-5fb3-4659-a5ae-8d50a813298a	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$N99IHXMqFYVmqeQDfUiEZ.VA6snD5NAtwtlmkYhB1Hqdr4A/uTWN.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-27 06:45:14.533066	2026-07-27 08:53:10.909	2026-07-27 07:53:15.864963
e9782ec8-d057-4ac3-b93a-cb5c64e559f3	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ADDIZavrsT9sgj/Bqfh8o.OI4w6mftOdGOe1GGKTPOgztA7Ce354K	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:18:27.41604	2026-05-07 09:18:26.968	2026-08-01 17:33:44.104589
a17d77b9-f3fb-4878-ad6b-8a972f2e0056	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$TiUEXArtWaytS.4ojMUkeOti2Zu0EtoRuz8BCBLbJxuGRkyhl12D6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::ffff:10.69.13.99	2026-07-30 13:31:48.166814	2026-07-30 15:01:25.203	2026-07-30 14:02:56.301461
f1450113-1805-4e65-a79c-6b88a1e67430	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$68L9Y9wwZMwJ0ivfdNokA.5fnovfYzjefbbvBEuqHMddKsDqqSH6u	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:48:41.480168	2026-05-07 09:48:41.019	2026-08-01 17:33:44.104589
4c038c23-398f-4ca1-8aa9-10efe5c45f76	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$mH2pZsXDL9cZPk7UGkaL2uFzZOnHeD14ltjnRg/Zux/0VghT.3.8K	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	117.18.17.106	2026-08-12 21:05:10.038074	2026-08-12 22:05:09.662	\N
0c476d52-5613-4a34-ab0b-fd5e06e84ccc	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$BBkiPbo7xDLA8c/I.ke/Ve.EFUNPeE3aW.6wANnJ1eJGa8RVz.oJC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	::1	2026-09-17 20:31:57.889755	2026-09-17 21:31:57.512	2026-09-17 20:32:56.346399
e8a454b4-c0da-4e3f-822a-14e2dac65e68	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$A.yfswrjTXq4rfk9bTArVO0GYA24Gr1XP6mkekSqR/aFf/rlYb08G	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	::1	2026-09-10 11:51:18.13289	2026-09-10 13:44:58.736	\N
32d5b7fa-2cfa-47e2-a30f-b265e6b3c54c	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$ggjEiiCYKPqLcoCIpcS2OOqEJS5ebE8txg94n0/91gL7nryzUcXma	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	::1	2026-09-12 11:05:34.646106	2026-09-12 12:05:34.252	\N
5b947fc9-ebb5-40b1-acb2-7cb224762a29	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$6O9uJ0rWcJx3p3CfCyY6o.IYMLkuUl54jO6ZGDkMdSR4fNguDp82e	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-19 21:00:58.259449	2026-08-19 22:00:57.786	2026-08-19 21:01:32.883161
257df0d2-1e37-4d5f-bd29-72c6a812d37c	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$KM2NK4IDrUEMa/ze1CRf8uFrq/gOIgkXyahYricZxiogLLY8ioiDG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-26 17:34:43.150272	2026-08-26 18:34:42.761	\N
86b5a3a6-056f-42a8-b102-03582e5a0011	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ejqoqWoFnzGmGCXHJwS25ub1IBM/2pJ.Z3R/AKoKNk2v.8J3SvmHa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-26 17:36:39.792529	2026-08-26 18:36:39.418	2026-08-26 17:38:05.153443
c3d1c82f-a2c7-4561-bbb6-7070735e76de	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$2ilgi8bA2wiUS2JzL4393.fZ.lzqscdqKv2/aEgAf0BgOFr0.amga	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36	::1	2026-09-09 08:46:25.577555	2026-09-09 09:53:44.198	\N
2e476c73-aa1c-49f1-8943-17900f565e8a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$tS0RMVYiT5WOav2FR618deybvvBAicWb26gORpkEaZaIS3kYKBsVG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36	::1	2026-09-09 11:04:48.673642	2026-09-09 12:04:48.291	\N
8299dc4e-0d83-4481-931e-b9faebf994d6	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$HOvdhqXckSI/qpe4IWFjNejsQ9Rf.VApLE2DGB64fldBQkz/JEth6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Code/1.137.0 Chrome/148.0.7778.280 Electron/42.10.0 Safari/537.36	::1	2026-09-13 18:48:58.700398	2026-09-13 19:48:58.315	2026-09-13 18:49:14.590724
14cc26f2-5b5a-41c6-ad37-91626097822b	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$YMrFu6OJR.WRqOpA7SkPgOgeFVmfXMIVndfUrHCfe6k9ePp6o4Jj6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::1	2026-07-23 13:41:45.190032	2026-07-23 14:41:44.811	2026-09-24 04:21:46.660381
81828c38-730f-4689-9fe2-4996ff98e61f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$BVwXAhQKnunAaGg.gGkTyO56ehXOmF94WaKaNCyvlv5.7A4T0BMSK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	117.18.17.106	2026-08-12 21:05:26.336956	2026-08-12 22:05:25.963	2026-09-24 04:21:46.660381
fb180236-2094-477a-8561-61fd515143ff	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$pGftl/O5rJV1GIzgSalH9eQ5m6Voi4d4xKvgYslgK.kaoobdg2/Tm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	::1	2026-09-12 11:06:25.917831	2026-09-12 12:06:25.543	2026-09-24 04:21:46.660381
acb6d942-9b9e-44f0-9849-5467ed3d2d9b	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$tTokcTj35vCih/KW8PNd2.SniVFxUnJkdLZtHLIMfRS9xK8x7ItCy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-26 17:35:58.619632	2026-08-26 18:35:58.245	2026-09-24 04:21:46.660381
a5cd3260-17be-4b38-89f6-c0cd78d11930	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$0lWXeMV9/zOCxkyAKEi5SOAHRYTLw9KESmBxcuLlJRVsrnizMUdOC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	::1	2026-09-13 09:41:25.824366	2026-09-13 10:41:25.45	2026-09-24 04:21:46.660381
10cdc90e-9805-4f3a-bded-e27c08373896	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$Ajh5p7smhgjW4nE35al8RO6hMCZWSP9QHGa.n0Zgu0wdEPsC6V8iG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	::1	2026-09-17 05:12:15.82181	2026-09-17 06:12:15.343	2026-09-17 05:13:24.740226
84517875-92aa-442e-9888-cbaf0ed3d7d0	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$tY.lgCFOzEvku0dE7aO9g.d3yKlytxEmKnDsyDRMB2z6IV5cPTxl.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.68.97	2026-09-22 11:15:56.055693	2026-09-22 12:15:55.774	2026-09-22 11:17:11.35841
f0857300-0d90-4082-9841-cd5922fd229d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$c4g/NehL4LQKT6FyUOh53eaY5koQ36jEhaDqn.s6lToRfZoQP0h2u	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.68.97	2026-09-22 11:18:06.696752	2026-09-22 12:18:06.407	2026-09-22 11:20:00.655292
86a5cfc3-de05-4a5d-960a-2b78f563ae49	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$qXruAeq5c2Ph1x.fDe4hE.vccGXuSzerVJx9/ZJ6dE0yeFiNojzCS	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36	152.233.68.97	2026-09-22 11:20:24.468403	2026-09-22 12:20:24.188	2026-09-24 03:25:12.239543
9ce60cb1-3df2-4487-bc85-2d52359aa7be	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$eApgyodAdpXP137qln6ZjeX.oubUp2YVHXlnT15txqtdTg/RV.hhi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.68.97	2026-09-22 11:20:05.223584	2026-09-22 12:22:47.01	2026-09-22 11:24:43.231108
cb3e5e89-cb77-4fef-b901-dd8d65e67977	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$yFuFoT39bCTWK882UPd0Guw78G0dVL2p4P003Nq6.FOAkCB5HwIsy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-22 11:26:45.044017	2026-09-22 12:26:44.762	\N
82332562-f2c7-4f33-9dc7-7e87bd3aa536	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$9Sp32SABAikh3vagRcSP1O6eL8GEmolzAz0n/THlOsxbTxmog4Ceu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-24 01:30:05.345903	2026-09-24 02:30:05.042	2026-09-24 01:30:55.083045
502bc5a8-74fd-4a8e-a65a-17a1dd921108	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$MbhSFDvFMgt84MbIi1pgduMPzOwa.SnsDt8uFbKGskHdPGE/XpdEC	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36	152.233.15.123	2026-09-22 11:21:21.724553	2026-09-22 12:26:15.606	2026-09-24 03:25:12.239543
976ddc30-9884-4e78-8e3f-472864ff13b0	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$PU7scfKpQixDCBxa2w8BNeV/r7RcAKy/a0hsTO0ItjWXkN.JJB4Pm	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Mobile Safari/537.36	152.233.15.120	2026-09-22 14:21:59.702698	2026-09-22 15:21:59.421	2026-09-24 03:25:12.239543
abda3470-e731-45b7-b88a-2f0db2af6d62	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$8alhQEjstEFqaSAUoKKzOejlYlQ95n5eEuVOX0oNiZRY4LMlTak8e	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-24 01:29:21.64445	2026-09-24 02:33:58.614	2026-09-24 03:25:12.239543
e222fa79-f5b4-4d88-bda7-3250b6aab3b3	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$IVTt8gfRBgkN1Y6q6pyYdOE.LrlUQIHKVfXWQR9fKoBIp030401QS	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.68.98	2026-09-24 03:03:15.768271	2026-09-24 04:03:15.522	2026-09-24 03:25:12.239543
099cabfe-7456-46e1-b0ad-fa83bf3bf9ae	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$LSdVOhvkMWzMRaeX/CVNpu0aH8b34rLDVmpJztdJWCMpheojfP43S	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.2	2026-08-04 13:16:58.96888	2026-08-04 14:48:35.849	2026-09-24 03:25:12.239543
0a394706-dd86-43b3-a4c7-d9ccfe048ed1	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$iszYhbnMTgZabY5.ivu96.mByYB6fU6SWt0PLmqElETmsC6CmcLjy	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.2	2026-08-04 11:08:38.615174	2026-08-04 12:10:43.972	2026-09-24 03:25:12.239543
8cb4d9a8-cf0a-4ad8-be88-a794177aa399	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$jbTtAQ7na91p.q0A/eYPge5Dmo.c3biHM/U./b2AUGJHjF68LAf2q	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Mobile Safari/537.36	::ffff:192.168.1.2	2026-08-04 11:12:43.863252	2026-08-04 12:12:43.482	2026-09-24 03:25:12.239543
c61a6616-f3b5-4440-a68e-542a59edafbb	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$GNccxZxk8gOvNJJ9/JpT6.fiBK6CqLMbaw47o3ptEwIeHAPJ2kIU2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-08 17:03:42.018215	2026-08-08 18:03:41.633	2026-09-24 03:25:12.239543
ab5701ee-02f1-40e2-af5d-925736171c66	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$WBnP3jjHt2fz9XtYH8hMzuiL0CSL8NVw1EFysHd/TX.9glgy/cO1y	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-08 17:04:25.644207	2026-08-08 18:04:25.262	2026-09-24 03:25:12.239543
20bf5392-9d16-4a22-882a-da28bd274c87	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$nhnIITZTBHgiOcmgUwp.XOSbloMGdlvsux.l78JrWOilqbqQy1oGa	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-09 19:36:06.590621	2026-08-09 20:36:06.206	2026-09-24 03:25:12.239543
410d8e61-e34f-41f8-9575-c93bb1b9a12e	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$gEdwUd6JywUK7qp2JLOaZepgRGpzPWMtBNfWXvXvPQSpKgp12Gbgq	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.68.98	2026-09-24 03:04:32.75242	2026-09-24 04:04:32.461	2026-09-24 03:25:12.239543
573e7a3f-31d7-478a-839a-2e527ca5d2b0	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$qiNn61.CdCqpFQKisQ1Uw.BTFti2o3l9zawpEQWqn3u1rwpVJxN.i	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-22 11:25:51.509254	2026-09-22 12:25:51.228	2026-09-24 04:21:46.660381
32e7244a-0941-4119-9bce-eb9148e2168b	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$i4OZtyqMjaxvtRbRTjjAUeMJnprrGjX/qC2M9XUyis7gxdP/.qZFO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-22 11:26:04.645144	2026-09-22 12:26:04.365	2026-09-24 04:21:46.660381
d20352c8-cc6c-46e5-a21e-a61a7ca3fa3e	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$rf1CStY4VFdYpdJKtkjFd.CaqXx3pkqSYX4CDDPPpozlQL8oGO0UO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.68.97	2026-09-22 11:32:39.491663	2026-09-22 13:16:31.532	2026-09-24 04:21:46.660381
056e6c26-8f7b-4137-bc2b-28cb96cce478	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$E1cdUVhGKEl8QWbDVF.EnuQGCNdaJ3agd30BfZprkzUFtUrs05CDe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.68.97	2026-09-22 14:19:47.359156	2026-09-22 15:22:21.531	2026-09-24 04:21:46.660381
67153889-596d-41b3-8438-f799ccf40e0d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Ly7/QAkLlf6BToeGfYVciuWDv5rQMUFS/ZnAz2sL0rEwsKToPfcqy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-09 19:45:38.102857	2026-08-09 20:45:37.729	2026-09-24 03:25:12.239543
f9bc5acf-8959-4b63-94f3-ec44b3d46310	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$PFaMDkWCgT0q2TqrvPymA.UkwdXrDb975Rq2ufL5OAjCxfSccvZdW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-09 20:53:40.050869	2026-08-09 21:53:39.677	2026-09-24 03:25:12.239543
5b800862-2a54-426f-99f5-4cec3e7a0c19	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$c/u4yx3kN.gtIHbk55roqeNpWfp/zw8PaRvDUEFBx9/uCS35UG0Ye	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-09 23:23:09.244185	2026-08-10 00:23:08.866	2026-09-24 03:25:12.239543
cf18574d-b704-4bbe-a75d-ffae1d47c640	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$kp6NFrNw5ItdEOLDOUlXWuJN4IZWvFxmzrpq9pgnqjSmbjJ8zowM6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	::1	2026-08-09 23:23:17.527479	2026-08-10 00:23:17.151	2026-09-24 03:25:12.239543
a4a325c8-3622-4a90-ad4f-25d6e91ec0fe	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$X.DorUi0o0oi1mGddH0WhubWecK1uRZ3IwVkZOmC5AE.zuwdwGbN6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	117.18.17.106	2026-08-12 17:07:47.892037	2026-08-12 18:07:47.437	2026-09-24 03:25:12.239543
ac667eff-488d-497c-b145-8893a6277fcb	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$x4UzbeSMtCUJ0cyVsFnkmO2RpNKC.LR39FbTWyU0sf2Ljt9B5QBNq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	117.18.17.106	2026-08-12 17:10:55.539213	2026-08-12 18:10:55.162	2026-09-24 03:25:12.239543
4d22c0ad-75da-4425-b5a9-5b2dd21695ef	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$iyPwgI.AL84/qg/4mT6bh.3BlFtUjST0Wpf19DsB6AdffmMepRpRu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	117.18.17.106	2026-08-12 21:03:54.570341	2026-08-12 22:03:54.184	2026-09-24 03:25:12.239543
2c141ca5-0dae-44c7-81df-79663624f3dd	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$tMnoKDdLSQmbNeeH7YNHX.AG/4fuhX.PxhqDVrUF7MBAcrZpcJUeG	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Mobile Safari/537.36	117.18.17.106	2026-08-14 13:09:35.966939	2026-08-14 14:21:16.265	2026-09-24 03:25:12.239543
18df4f5c-afb9-4a8e-bbda-c69adccc617d	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$VeGq3O7OprLH8XWectteqetV0atQ6W2AyEVHjSC0JrsvsiYD.AFRS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/151.0.0.0 Safari/537.36	117.18.17.106	2026-08-14 13:02:08.836065	2026-08-14 16:41:37.303	2026-09-24 03:25:12.239543
c57c867e-2c0c-45d3-a069-359679e18c81	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$uKshcOrvksR7V8peAh20uegiRWqJpI/JA6wP7qHU7ol8rbid8oZvq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.68.97	2026-09-24 03:04:46.498469	2026-09-24 04:25:10.165	2026-09-24 03:25:12.239543
4833d250-86d5-41dd-adcd-6f9857f67f3c	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$4htcy1W06BrYrT1ecEfPK.7hrA5uhK9U1KZgw1iIkHtwF5pFxQNnK	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.68.98	2026-09-24 04:06:14.646229	2026-09-24 05:06:14.361	2026-09-24 04:07:19.523499
a8061ff0-db61-4f24-a084-8be248561704	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$WAi3COucYX81Srh3oy03CeWuvTcMQB.cGK3Rjbxd.GxPOVBPYGUl6	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.68.97	2026-09-24 04:18:04.230518	2026-09-24 05:18:03.946	\N
5162c153-4ad5-410d-a152-c55a1d373a94	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$aRXw8zNPdrpsBDvcdqEt6OOJ7/I5RKOinJkYkIPf1PSvgi2Oi3BA2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 10:55:31.436287	2026-05-04 12:11:49.921	2026-09-24 04:21:46.660381
b5b2ad10-2e4d-4f4c-9a7b-78e9bc33f8ac	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$CTKmlxAWuAj5G.ATyYoyOufmbaNXtaLBnaqTwKv3vlslyiOvRNmBm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 11:38:17.215434	2026-05-04 14:02:01.318	2026-09-24 04:21:46.660381
6860d2db-db03-435f-b224-253909aeb04d	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$WZ7lW5XdeeUOi1QNgp7P0.yp2B/xmxuCuUjebJMODENa8wKgGTpVS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 16:48:47.164537	2026-05-04 19:51:57.492	2026-09-24 04:21:46.660381
8ee8c29f-9864-438d-9bf3-b6c71bc8d696	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$huanjJWZzRCN0pT/s6LJIeJKpCPlHVY8P9WOXMk/ul5GcPBFayUGq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 20:48:54.812079	2026-05-04 21:50:55.451	2026-09-24 04:21:46.660381
cdac04ec-df8c-4aed-9c6d-a36825b98f08	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$.tYIcS8CYal3xgusthlOLOBeUMkwzRGgUNQDJyEMinEFWwKYykz8e	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 08:39:45.247449	2026-05-05 09:39:44.871	2026-09-24 04:21:46.660381
35b3a973-55bf-4321-9cf1-607a00759eb6	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$0F7Ixspu9r6PnlPmFuVJxOykPzBrorr6JlaueglsmZUnheZwAGzZO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 22:55:51.743459	2026-05-05 00:16:37.595	2026-09-24 04:21:46.660381
f41bbba7-6a5e-49f1-be54-d5f3a4a4f562	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$X8YDyLqAyUhapLggxlvQ9uLsW6FAmho/NL7JauYbDPc4femrr/3.C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 16:45:50.478375	2026-05-05 17:58:44.425	2026-09-24 04:21:46.660381
44adbee8-eb89-4eb4-a226-3876976e283d	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$Ae3Krjy.tA0g9cfwDv/TseEkL2Pc9N0gRotV.fReaNBwUo7Nclyk6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-04 23:19:29.50514	2026-05-05 00:34:37.116	2026-09-24 04:21:46.660381
32639dea-d5f0-46f9-b75b-2a4338d4346f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$D3g226dhEcNuqUHO47fYd.LPgpzmaqLsLLbPb2OYfD8c7ZbbRzmRW	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 00:10:46.071342	2026-05-05 01:10:45.688	2026-09-24 04:21:46.660381
845ad5fc-4f4c-45d4-90b3-a35b3f06822f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$WXcUbxq6mk/78kJ9NZb7.eGAGj4g/Y67EqQ9rWle4HaGp3ezdLiIq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:18:24.332351	2026-05-07 09:18:23.888	2026-09-24 04:21:46.660381
21d7a849-a43e-4a55-a144-60aff5d200df	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$FEt9UdQlbT7rgSsetTFRzeQxKec78Dyoq/sYm3emvBiw48bv3XaOi	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 11:47:47.241092	2026-05-07 16:54:41.954	2026-09-24 04:21:46.660381
804d32fd-4cce-45c9-8364-cfdb972ed20d	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$z2hnbju0rILL7xnapUAhdeiem.zIp/Z313rxPVGVVtNLrphC8u/Ga	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-05 13:22:00.297822	2026-05-05 14:21:59.828	2026-09-24 04:21:46.660381
827b438d-666e-4a4c-a7ed-11aeb8bf83ff	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$syb0JXSkxCATymkMNMrIl.Mjo4053EJW8kxi.oxKPsVBFfoByqy6C	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 08:48:35.964093	2026-05-07 11:14:09.566	2026-09-24 04:21:46.660381
cf57e203-14a7-4ecb-9ffc-d50fe7c64ffc	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$tetKtGZnh2o8zUVqRbP.QeqhiOhOnWlpxfz1H.Vv2j3PVWGIp6koO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36	::ffff:10.69.13.99	2026-07-30 13:31:15.857897	2026-07-30 14:31:15.474	2026-09-24 04:21:46.660381
3af9d2f1-f56a-48fc-a7c8-cee1b80629d5	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$FUVwWdx1VojlXSnOUIem6e.RBgCy5.5HwnQuIHARJwRm6lp6aYcmq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-10 10:56:36.178295	2026-05-10 13:23:27.212	2026-09-24 04:21:46.660381
86ca394b-475a-4f53-898d-53874715fbd2	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$JgEPbD3l5ZNgLwsMcaBmKeiBgI/PTCrcSjP2b6pT95o9CcVXYtC2m	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 23:51:31.825246	2026-05-10 00:51:31.443	2026-09-24 04:21:46.660381
9f672802-2118-4876-b11f-c02b5945ff7e	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$sa8NtSC.Mccg.NfHFlbApeCjjho8xoTdwwo5kezOLhKLAM.Nonpdq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 18:48:57.427447	2026-05-08 20:27:20.981	2026-09-24 04:21:46.660381
9faacd1f-dfe0-4846-ab7b-b8f23a890e03	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$y4eEXCXwuOTcuRTOYKEUq.esqUL8QcA29CTs9ecRG4OsTz0VMfG5.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-07 18:29:17.537039	2026-05-07 22:43:40.471	2026-09-24 04:21:46.660381
e58e13bc-7e7f-41dc-ac94-6ae3d8a3fe22	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$IOCHwAmh0bpSpsq767PKL.PJnzaCMOzHjyg6yK6pEo4ihaa1.FHou	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-08 08:26:10.949684	2026-05-08 09:28:21.077	2026-09-24 04:21:46.660381
e1e8d98d-6717-4905-a87f-dc87d59a094b	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$/LaTiQSX/Uxia7TKthwwD.xoOQvZo/CNR7ojkAUGCfGl022TlFiym	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-09 09:11:51.625414	2026-05-09 10:11:51.149	2026-09-24 04:21:46.660381
05fc8602-5afe-4c3d-acf0-b181dcc2ee6f	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$IF5ngn/l4oVzDLKZuczY9OqV8K9rkljJqy2yrw342yhBEMT2o91pC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36	::1	2026-05-11 00:21:06.93273	2026-05-11 02:27:43.732	2026-09-24 04:21:46.660381
3271cd6f-fcfb-498e-9180-95f74a2a6c76	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$DWgJ83tLzx0JdJFdhO6oDeKVqkvhNUID0Lg.RxE40lTgwxhSsNWYS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36	::1	2026-05-13 07:48:41.681906	2026-05-13 08:48:41.301	2026-09-24 04:21:46.660381
b2371af6-e030-4178-b6e1-180f3572ccc4	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$/iYD3uB7vtqdf0KFZcA.sOUScNxoNOT/YhRxT761bo5n/mFGlDgKe	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-24 03:00:19.324871	2026-09-24 05:21:11.924	2026-09-24 04:21:46.660381
5bab3f57-6354-4558-861b-49e821e29688	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$AJsWxzZOSYPUtnW87Q5Rb.6j/RaekV9kjmbpQA6dq5PWX.W33a0Pi	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.15.120	2026-09-24 05:23:54.248547	2026-10-08 05:23:53.968	\N
41fe0369-37ba-4b1e-8282-549d2e53694a	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$.B7mJtTkTLqgq32rimo9uuYhIPVvn8v8uojTkrKy/JWF3sGapRg82	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.68.97	2026-09-24 05:24:30.76919	2026-10-08 05:24:30.485	\N
df67826d-21b7-48d1-aa1d-6a95d7106d69	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$oY8PNNQww6Rwts2ZS1bfruLQv3XOZ/mQBCrVHWqFrNvAb.NHcIZi.	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.68.97	2026-09-24 10:57:46.902117	2026-10-11 14:17:13.162	\N
d3a4c901-06fc-463c-a090-e4f206d333c6	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$4AUTxBEXyiQoKJ4dpyVduOBqJ07ITgf.WdZ8.dFODKgHL.nrx0GmS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.68.98	2026-09-24 07:14:36.093041	2026-10-08 08:04:31.1	2026-09-24 08:10:12.370245
eb29f517-bfcd-44b2-93d0-9ac48c4e6f53	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$IypHPxbA7tYUJvi3K3LN.u9dEEKFK.RD2d3pUDPiZBvlIUDj0mY8C	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.15.123	2026-09-24 07:49:57.774457	2026-10-08 08:06:36.294	2026-09-24 08:16:08.112365
8b97b47a-dd2d-489b-b50d-e21385964190	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$rynrhBLJ5ogESI3UFfF.eOZhWq0kwbVBnrp3RLIVbqwVVxBQq3Ur6	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.68.98	2026-09-24 08:16:32.523925	2026-10-08 08:16:32.297	\N
d4fd4f61-f44c-46b7-b16c-80639e522e14	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$vvaEfG1F3AM6WWqyNj/XIObrBtTXgE8JvAYN7lShrJCg7xT5GezZO	Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Mobile Safari/537.36	152.233.15.121	2026-09-24 08:17:12.45186	2026-10-08 08:17:12.245	\N
e16e7f1f-bc95-45de-b154-b5ae07be1113	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$Ug1pO9jXbbocayVQv5Y15e.QiVavEzxZ7fcjWtzNtQIFHws9Jfvoy	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-24 08:17:47.793109	2026-10-08 08:17:47.598	2026-09-24 08:17:57.818365
15b71810-fe60-4bc4-9793-724ec6105d14	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$BoJWrggCsB416BGpaSOVh.eeXZvO6OUNTTfPr6WltM8n2g7N0Afgu	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-24 08:18:18.753208	2026-10-08 08:18:18.554	2026-09-24 08:19:11.111582
466cdfe9-349e-4f2c-9104-d3c37f6808e4	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$JcxPKp/ws4z91uWax2Lvgu9lK6wiafIShJQ7WyCGYsbC9XSP6.EY2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-28 01:35:23.213134	2026-10-13 00:49:58.801	2026-09-29 09:03:20
15784c28-9c7a-4632-b34a-3fc11be01771	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$QZNJ7elFU6KYOdZ9nCpPd.qIJWdVZjPSqC2XIweYJzk2l3dZ1rEHm	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-28 01:35:01.658709	2026-10-13 00:53:08.715	2026-09-29 09:03:20
a885e8ab-93ea-4f05-b595-74f37d596a55	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$SYayDvAajSWCpJKYpeTYHO4AJcop4cYbuiY90o9id.pPUnL6dKriG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-28 01:37:09.064485	2026-10-13 00:53:11.318	2026-09-29 09:03:20
936c9721-7ed1-42f8-b1ae-58662f5fda21	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$53lvyIF2msAtrQFtlsHBfer8sENhtXEaGMqdVQR.vgMK8WwlASWze	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-29 00:54:33.530593	2026-10-13 00:54:33.25	2026-09-29 09:03:20
7b11f07d-5789-473b-ae98-8fd5e41cfe14	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$pDCH3e8jRRyiJhZKdinrYe89KOVnKw3z3UB6sLkxyej1FSWln6NYS	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.123	2026-09-29 03:11:43.279058	2026-10-13 03:11:42.985	\N
58b43b6a-a95f-4db7-b649-cf6617a3ceec	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$WBfCmcewUvpxSLTaDs17UuFZrj7i.vT8ENODSIRewy3KUtHlfysze	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.123	2026-09-29 03:11:54.519433	2026-10-13 03:11:54.237	\N
6887d8ad-ec15-420b-9af8-a5a9a343706b	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$.Qg0mTXftiwsSZT0UrlkeuvK3nDvKTLdJB4kg2HwoEbHfxHuYerWO	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.123	2026-09-29 03:12:05.383008	2026-10-13 03:12:05.076	\N
5979387f-4174-4be6-ac97-931cba05fa64	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$WPCdt4qZeSp30Gv8/7jza.V/6MyMKqSenpnWfNMPdmYAlk4cMkri6	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-29 00:54:39.711546	2026-10-13 00:54:39.43	2026-09-29 09:03:20
09fd7758-c872-46db-876d-18e8d7636369	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$ZAZMSLn4B8LxY72CcjxObeAhJkTBmukioo/LMeSFZiOE79NgpLrsG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-29 00:55:00.341283	2026-10-13 00:55:00.055	2026-09-29 09:03:20
9cecf041-8e05-43fb-8c8a-81770beae480	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$p4oDV1i1mDywx4sRRHBE4.5Wr4hdYtgBpiKaa7d2G3HEjoxqYCDCK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.120	2026-09-29 00:55:28.004294	2026-10-13 00:55:27.711	2026-09-29 09:03:20
a6028e61-cb18-41af-b588-106d25e4931a	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$KCy6GVtT9ZGcoKCM0BIGSuxopQP1OzDxHsz2Ney7RxLWvPgpUlNBK	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.123	2026-09-29 03:12:38.267536	2026-10-13 03:12:37.986	\N
4cf3b5a8-f071-49a2-820f-749c58a7e269	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$k0f/aESZT9EHXHt4jdfg7eNWESY8eMNemdlCVogyTpoTjSyN2GQxC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.123	2026-09-29 03:12:43.681925	2026-10-13 03:12:43.394	\N
a343081f-a30d-461e-b0d0-1c276c6e3d19	81caf204-9368-484b-b200-f9d4bde5c87b	$2b$12$w/nSNrhvxZRrLdnKVVW13.yNzSa4DVxzvOeM140MkQ9CzXc.hPRBG	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-29 03:13:00.493627	2026-10-13 03:13:00.214	\N
9f6230dd-d0fb-490a-b26d-d7315699d779	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$maE0M0wD1lBjDjmyeQk5vOlJ.SOmYp3D8/5z5zHWzKRXD1lpnl3Dq	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-29 03:13:31.546577	2026-10-13 03:59:14.935	2026-09-29 03:59:16.252433
750d96c0-c0ba-4bdf-8ac9-8af59292a291	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$hDpNaBOW0bKAaVuOu6P5cO9pQJVnCRP5/rUXHxtjdIFQ4./P.OUgC	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-29 03:59:28.62859	2026-10-13 03:59:28.328	\N
46e4ed34-8b25-4e5f-a094-293596283ec6	4f9150c7-e6ed-4ea2-8690-4fb9f699240c	$2b$12$5K0/TN9JgNb5psuKd4XPK.rdBggo6QXKH15ry.6AMZ.8ofwDXEGz.	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.121	2026-09-29 03:12:19.192281	2026-10-13 05:43:19.998	\N
e1906605-92e4-4e4b-81d3-af54c5d9eac0	6181ac3f-3415-4dc9-ba6f-69be692100fa	$2b$12$rXSDMfs49uGprD3/oPv2pO6w/RMIrhmulxit5Uk3lkRPhowAL4rX2	Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/153.0.0.0 Safari/537.36	152.233.15.123	2026-09-29 05:42:07.16588	2026-10-13 05:57:08.293	\N
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
-- Name: idx_barang_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_barang_created_at ON public.barang USING btree (created_at DESC);


--
-- Name: idx_barang_masuk_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_barang_masuk_created_at ON public.barang_masuk USING btree (created_at DESC);


--
-- Name: idx_barang_masuk_id_barang; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_barang_masuk_id_barang ON public.barang_masuk USING btree (id_barang);


--
-- Name: idx_barang_nama_barang; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_barang_nama_barang ON public.barang USING btree (nama_barang);


--
-- Name: idx_detail_transaksi_id_barang; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_detail_transaksi_id_barang ON public.detail_transaksi USING btree (id_barang);


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
-- Name: idx_pelanggan_nama; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_pelanggan_nama ON public.pelanggan USING btree (nama_pelanggan);


--
-- Name: idx_transaksi_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaksi_created_at ON public.transaksi USING btree (created_at DESC);


--
-- Name: idx_transaksi_date_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaksi_date_created ON public.transaksi USING btree (date(created_at));


--
-- Name: idx_transaksi_id_pelanggan; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaksi_id_pelanggan ON public.transaksi USING btree (id_pelanggan);


--
-- Name: idx_transaksi_id_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_transaksi_id_user ON public.transaksi USING btree (id_user);


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

\unrestrict EQE0Bl4slAcBhigARoV5IT3W0C0wyFrslAxgMFxlZ0dAi2e3rXIj8fGflmFcT06

