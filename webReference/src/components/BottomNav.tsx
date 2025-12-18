import { Home, Search, Library, User } from 'lucide-react';

interface BottomNavProps {
  activeTab: 'home' | 'search' | 'library' | 'profile';
  onTabChange: (tab: 'home' | 'search' | 'library' | 'profile') => void;
}

export function BottomNav({ activeTab, onTabChange }: BottomNavProps) {
  const tabs = [
    { id: 'home' as const, icon: Home, label: 'Trang chủ' },
    { id: 'search' as const, icon: Search, label: 'Tìm kiếm' },
    { id: 'library' as const, icon: Library, label: 'Thư viện' },
    { id: 'profile' as const, icon: User, label: 'Cá nhân' },
  ];

  return (
    <div className="fixed bottom-0 left-0 right-0 bg-black border-t border-zinc-800">
      <div className="flex items-center justify-around py-2">
        {tabs.map((tab) => {
          const Icon = tab.icon;
          const isActive = activeTab === tab.id;
          
          return (
            <button
              key={tab.id}
              onClick={() => onTabChange(tab.id)}
              className="flex flex-col items-center gap-1 py-1 px-4 transition-colors"
            >
              <Icon 
                className={`w-6 h-6 ${isActive ? 'text-green-500' : 'text-zinc-400'}`}
                fill={isActive ? 'currentColor' : 'none'}
              />
              <span className={`text-xs ${isActive ? 'text-green-500' : 'text-zinc-400'}`}>
                {tab.label}
              </span>
            </button>
          );
        })}
      </div>
    </div>
  );
}
