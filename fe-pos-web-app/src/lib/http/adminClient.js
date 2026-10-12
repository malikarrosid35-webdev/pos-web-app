import { createAxios } from "./axiosBase";
const adminClient = createAxios("/api/admin");
export default adminClient;