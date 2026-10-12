export default function SearchBar({ value, onChange, onSubmit }) {
  return (
    <form onSubmit={onSubmit} className="mb-6">
      <div className="relative">
        <input
          type="text"
          placeholder="Cari barang..."
          className="w-full p-3 pr-24 rounded-lg border border-gray-300 focus:outline-none focus:ring-2 focus:ring-blue-400"
          value={value}
          onChange={onChange}
        />
        <button
          type="submit"
          className="absolute right-1 top-1 bottom-1 px-4 rounded-md bg-blue-500 text-white hover:bg-blue-600 active:bg-blue-700 cursor-pointer"
        >
          Cari
        </button>
      </div>
    </form>
  );
}