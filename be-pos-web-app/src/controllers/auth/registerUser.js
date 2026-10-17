import pool from "../../database/db.js";
import bcrypt from "bcrypt";
import { v4 as uuidv4 } from "uuid";

const ALLOWED_ROLES = ["owner", "admin", "kasir"];

const registerUser = async (req, res) => {
  const { username, password, role } = req.body;
  if (!username || !password || !role) {
    return res.status(400).json({ message: "Field tidak boleh kosong" });
  }

  if (!ALLOWED_ROLES.includes(role)) {
    return res.status(400).json({ message: "Role tidak valid" });
  }

  try {
    const hashedPassword = await bcrypt.hash(password, 10);
    const id_user = uuidv4();

    const newUser = await pool.query(
      `INSERT INTO users (id_user, username, password, role) VALUES ($1, $2, $3, $4)
       RETURNING id_user, username, role`,
      [id_user, username, hashedPassword, role]
    );

    res.status(201).json({
      success: true,
      message: "User berhasil didaftarkan",
      data: newUser.rows[0],
    });
  } catch (err) {
    if (err.code === "23505") {
      return res.status(409).json({ message: "Username sudah digunakan" });
    }
    console.error(err.message);
    res.status(500).json({ message: "Server Error" });
  }
};

export default registerUser;
