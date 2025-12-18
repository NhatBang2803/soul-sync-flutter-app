import { Settings, Share2, Bell, UserPlus, LogOut } from 'lucide-react';
import { ImageWithFallback } from './figma/ImageWithFallback';

export function ProfileScreen() {
  const menuItems = [
    { icon: Settings, label: 'Cài đặt', onClick: () => {} },
    { icon: Bell, label: 'Thông báo', onClick: () => {} },
    { icon: Share2, label: 'Chia sẻ hồ sơ', onClick: () => {} },
    { icon: UserPlus, label: 'Mời bạn bè', onClick: () => {} },
    { icon: LogOut, label: 'Đăng xuất', onClick: () => {}, danger: true },
  ];

  return (
    <div className="flex-1 overflow-y-auto pb-32">
      {/* Profile Header */}
      <div className="bg-gradient-to-b from-zinc-800 to-zinc-900 px-4 pt-12 pb-8">
        <div className="flex flex-col items-center">
          <div className="w-32 h-32 rounded-full overflow-hidden mb-4 bg-gradient-to-br from-green-400 to-blue-500 flex items-center justify-center shadow-xl">
            <span className="text-white text-5xl">👤</span>
          </div>
          <h1 className="text-white text-2xl mb-2">Người dùng</h1>
          <p className="text-zinc-400 mb-4">user@email.com</p>
          
          <div className="flex gap-6 text-center">
            <div>
              <p className="text-white text-xl">42</p>
              <p className="text-zinc-400 text-sm">Playlist</p>
            </div>
            <div>
              <p className="text-white text-xl">156</p>
              <p className="text-zinc-400 text-sm">Đang theo dõi</p>
            </div>
            <div>
              <p className="text-white text-xl">89</p>
              <p className="text-zinc-400 text-sm">Người theo dõi</p>
            </div>
          </div>
        </div>
      </div>

      {/* Menu Items */}
      <div className="px-4 py-6">
        <div className="bg-zinc-800/50 rounded-lg overflow-hidden">
          {menuItems.map((item, index) => {
            const Icon = item.icon;
            return (
              <button
                key={item.label}
                onClick={item.onClick}
                className={`w-full flex items-center gap-4 px-4 py-4 hover:bg-zinc-800 transition-colors ${
                  index !== menuItems.length - 1 ? 'border-b border-zinc-700/50' : ''
                }`}
              >
                <Icon className={`w-6 h-6 ${item.danger ? 'text-red-500' : 'text-zinc-400'}`} />
                <span className={`flex-1 text-left ${item.danger ? 'text-red-500' : 'text-white'}`}>
                  {item.label}
                </span>
              </button>
            );
          })}
        </div>
      </div>

      {/* Stats Card */}
      <div className="px-4 py-6">
        <div className="bg-gradient-to-br from-purple-900/50 to-pink-900/50 rounded-lg p-6 border border-purple-800/30">
          <h3 className="text-white text-lg mb-2">Thống kê âm nhạc</h3>
          <p className="text-purple-200 text-sm mb-4">Tháng này</p>
          
          <div className="space-y-3">
            <div className="flex justify-between">
              <span className="text-zinc-300">Tổng thời gian nghe</span>
              <span className="text-white">24 giờ 32 phút</span>
            </div>
            <div className="flex justify-between">
              <span className="text-zinc-300">Bài hát đã nghe</span>
              <span className="text-white">387 bài</span>
            </div>
            <div className="flex justify-between">
              <span className="text-zinc-300">Nghệ sĩ yêu thích</span>
              <span className="text-white">Luna Echo</span>
            </div>
          </div>
        </div>
      </div>

      {/* Premium Card */}
      <div className="px-4 py-6">
        <div className="bg-gradient-to-br from-green-600 to-green-800 rounded-lg p-6">
          <h3 className="text-white text-xl mb-2">Nâng cấp Premium</h3>
          <p className="text-green-100 text-sm mb-4">
            Nghe nhạc không giới hạn, không quảng cáo và tải về offline
          </p>
          <button className="bg-white text-black px-6 py-3 rounded-full hover:scale-105 transition-transform">
            Xem gói Premium
          </button>
        </div>
      </div>
    </div>
  );
}
