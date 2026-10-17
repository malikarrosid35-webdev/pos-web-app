import pool from "../../database/db.js";
import bcrypt from "bcrypt";

const updateUserById = async (req, res) => {
  const { id_user } = req.params;
  const { username, password } = req.body;

  if (!username && !password) {
    return res.status(400).json({ message: "Minimal satu field harus diisi" });
  }

  try {
    const existingUser = await pool.query(
      `SELECT * FROM users WHERE id_user = $1`,
      [id_user]
    );
    if (existingUser.rowCount === 0) {
      return res.status(404).json({ message: "User tidak ditemukan" });
    }

    // Only an owner may change an owner account; otherwise an admin could
    // reset the owner's password and take the account over.
    if (existingUser.rows[0].role === "owner" && req.user?.role !== "owner") {
      return res.status(403).json({ message: "Akses ditolak" });
    }

    const updateFields = [];
    const values = [];

    if (username) {
      updateFields.push(`username = $${updateFields.length + 1}`);
      values.push(username);
    }

    if (password) {
      const hashedPassword = await bcrypt.hash(password, 10);
      updateFields.push(`password = $${updateFields.length + 1}`);
      values.push(hashedPassword);
    }

    values.push(id_user);
    // Single UPDATE; never return the password hash to the caller.
    const updatedUser = await pool.query(
      `UPDATE users SET ${updateFields.join(", ")} WHERE id_user = $${
        values.length
      } RETURNING id_user, username, role`,
      values
    );

    res.status(200).json({
      success: true,
      message: "User berhasil diperbarui",
      data: updatedUser.rows[0],
    });
  } catch (err) {
    if (err.code === "23505") {
      return res.status(409).json({ message: "Username sudah digunakan" });
    }
    console.error(err.message);
    res.status(500).json({ message: "Server Error" });
  }
};

export default updateUserById;
