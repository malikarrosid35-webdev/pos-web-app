import { createAxios } from "./axiosBase";
const kasirClient = createAxios("/api/kasir");
export default kasirClient;