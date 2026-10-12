import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { login } from "./authService.js";
import PwaInstallBanner from "../shared/components/PwaInstallBanner.jsx";

// sweetalert2 is only needed when a login error occurs, so it is loaded
// on demand instead of being bundled into the initial login page chunk.
async function showAlert(options) {
  const { default: Swal } = await import("sweetalert2");
  return Swal.fire(options);
}

export default function LoginPage() {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const user = await login(username, password);
      if (user.role === "admin") {
        navigate("/admin/dashboard");
      } else if (user.role === "kasir") {
        navigate("/kasir/buat-transaksi");
      } else if (user.role === "owner") {
        navigate("/owner/dashboard");
      } else {
        showAlert({
          icon: "error",
          title: "Role Tidak Dikenali",
          text: "Role pengguna tidak dapat diidentifikasi.",
          confirmButtonColor: "#3085d6",
        });
      }
    } catch (error) {
      console.log(error);
      if (error.response?.status === 429) {
        showAlert({
          icon: "error",
          title: "Terlalu Banyak Percobaan!",
          html: `
            <p>${error.response?.data?.message || "Terlalu banyak percobaan login."}</p>
            <p class="mt-2 text-sm text-gray-600">Silakan tunggu <strong>1 menit</strong> sebelum mencoba lagi.</p>
          `,
          confirmButtonColor: "#d33",
          timer: 5000,
          timerProgressBar: true,
        });
        return;
      }
      const errorData = error.response?.data;
      const errorType = errorData?.error;
      const errorMessage = errorData?.message;
      switch (errorType) {
        case "USERNAME_NOT_FOUND":
          showAlert({
            icon: "error",
            title: "Username Tidak Ditemukan",
            text:
              errorMessage || "Username yang Anda masukkan tidak terdaftar.",
            confirmButtonColor: "#3085d6",
          });
          break;
        case "INVALID_PASSWORD":
          showAlert({
            icon: "error",
            title: "Password Salah",
            text: errorMessage || "Password yang Anda masukkan tidak sesuai dengan username tersebut.",
            confirmButtonColor: "#3085d6",
          });
          break;
        case "SERVER_ERROR":
          showAlert({
            icon: "error",
            title: "Kesalahan Server",
            text:
              errorMessage ||
              "Terjadi kesalahan pada server. Silakan coba lagi nanti.",
            confirmButtonColor: "#3085d6",
          });
          break;
        default:
          showAlert({
            icon: "error",
            title: "Login Gagal",
            text:
              errorMessage ||
              "Terjadi kesalahan saat login. Silakan coba lagi.",
            confirmButtonColor: "#3085d6",
          });
      }
    }
  };

  return (
    // Container Utama: Full screen, relative positioning untuk background
    <div className="relative flex min-h-screen items-center justify-center overflow-hidden bg-gray-900">
      {/* Background Image: Absolute agar tidak mengganggu layout, pakai object-cover */}
      <img
        src="/tokokelontong.jpg" // Pastikan file ini ada di folder 'public'
        alt="Background Toko Kelontong"
        className="absolute inset-0 h-full w-full object-cover"
      />

      {/* Overlay Blur: Memberi efek blur pada gambar di belakangnya */}
      <div className="absolute inset-0 backdrop-brightness-15 bg-white/10"></div>

      {/* Konten Form Login: z-10 agar di atas background dan overlay */}
      <div className="relative z-10 w-full px-4 sm:px-0">
        <div className="mx-auto mb-4 max-w-xs sm:max-w-sm md:max-w-md">
          <PwaInstallBanner />
        </div>

        <form
          onSubmit={handleSubmit}
          className="mx-auto w-full max-w-xs sm:max-w-sm md:max-w-md bg-white p-6 sm:p-8 rounded-xl shadow-2xl"
        >
          <h2 className="text-xl sm:text-2xl font-bold mb-6 text-center text-gray-800">
            POS Web App <br />
            <span className="text-blue-700">Toko Kelontong</span>
          </h2>

          {/* Input Username dengan Icon */}
          <div className="mb-4">
            <div className="relative flex items-center">
              {/* Icon User dengan Pembatas */}
              <div className="absolute inset-y-0 left-0 flex items-center pl-3 pr-2 border-r border-gray-300 pointer-events-none">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5 text-gray-500"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fillRule="evenodd"
                    d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                    clipRule="evenodd"
                  />
                </svg>
              </div>
              <input
                type="text"
                placeholder="Nama Pengguna"
                className="w-full p-2.5 pl-12 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition text-sm sm:text-base"
                value={username}
                onChange={(e) => setUsername(e.target.value)}
                required
              />
            </div>
          </div>

          {/* Input Password dengan Icon */}
          <div className="mb-4">
            <div className="relative flex items-center">
              {/* Icon Kunci dengan Pembatas */}
              <div className="absolute inset-y-0 left-0 flex items-center pl-3 pr-2 border-r border-gray-300 pointer-events-none">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="h-5 w-5 text-gray-500"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fillRule="evenodd"
                    d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"
                    clipRule="evenodd"
                  />
                </svg>
              </div>
              <input
                type={showPassword ? "text" : "password"}
                placeholder="Kata Sandi"
                className="w-full p-2.5 pl-12 border rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition text-sm sm:text-base"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
              />
            </div>
          </div>

          {/* Checkbox Tampilkan Password */}
          <div className="mb-6 flex items-center">
            <input
              type="checkbox"
              id="showPassword"
              className="mr-2 h-4 w-4 rounded border-gray-300 text-blue-600 focus:ring-blue-500"
              checked={showPassword}
              onChange={() => setShowPassword(!showPassword)}
            />
            <label
              htmlFor="showPassword"
              className="text-sm text-gray-700 select-none cursor-pointer"
            >
              Tampilkan Password
            </label>
          </div>

          {/* Tombol Login */}
          <button
            type="submit"
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-semibold py-2.5 rounded-lg transition duration-200 text-sm sm:text-base focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 cursor-pointer"
          >
            Masuk Aplikasi
          </button>
        </form>
      </div>
    </div>
  );
}