import ownerClient from "../../lib/http/ownerClient.js";

const addHistoriTukarPoinOwner = (data) =>
  ownerClient.post("/histori-tukar-poin", data);

const getHistoriTukarPoinOwner = (params) =>
  ownerClient.get("/histori-tukar-poin", { params });

export { addHistoriTukarPoinOwner, getHistoriTukarPoinOwner };
