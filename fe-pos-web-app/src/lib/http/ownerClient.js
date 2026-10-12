import { createAxios } from "./axiosBase";
const ownerClient = createAxios("/api/owner");
export default ownerClient;