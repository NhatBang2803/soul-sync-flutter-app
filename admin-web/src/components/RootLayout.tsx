import { NavLink, Outlet } from 'react-router-dom'
import {
    LayoutDashboard,
    Music,
    Mic2,
    Disc3,
    Tag,
    ListMusic,
    Users,
    Menu,
    X,
    Sparkles,
    Podcast,
} from 'lucide-react'
import { useState } from 'react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'

const navItems = [
    { href: '/', label: 'Dashboard', icon: LayoutDashboard },
    { href: '/songs', label: 'Bài hát', icon: Music },
    { href: '/artists', label: 'Nghệ sĩ', icon: Mic2 },
    { href: '/albums', label: 'Album', icon: Disc3 },
    { href: '/genres', label: 'Thể loại', icon: Tag },
    { href: '/playlists', label: 'Playlist', icon: ListMusic },
    { href: '/podcasts', label: 'Podcast', icon: Podcast },
    { href: '/users', label: 'Người dùng', icon: Users },
]

export default function RootLayout() {
    const [sidebarOpen, setSidebarOpen] = useState(false)

    return (
        <div className="min-h-screen">
            {/* Background Effects */}
            <div className="fixed inset-0 pointer-events-none overflow-hidden">
                <div className="absolute top-[-20%] left-[-10%] w-[600px] h-[600px] bg-[hsl(var(--primary))] opacity-[0.03] blur-[120px] rounded-full" />
                <div className="absolute bottom-[-20%] right-[-10%] w-[500px] h-[500px] bg-[hsl(var(--accent))] opacity-[0.04] blur-[100px] rounded-full" />
                <div className="absolute top-[40%] right-[20%] w-[300px] h-[300px] bg-[hsl(var(--primary))] opacity-[0.02] blur-[80px] rounded-full" />
            </div>

            {/* Mobile overlay */}
            {sidebarOpen && (
                <div
                    className="fixed inset-0 bg-black/60 backdrop-blur-sm z-40 lg:hidden"
                    onClick={() => setSidebarOpen(false)}
                />
            )}

            {/* Sidebar */}
            <aside
                className={cn(
                    "fixed top-0 left-0 z-50 h-full w-72 ultra-glass-card rounded-none transform transition-transform duration-300 lg:translate-x-0",
                    sidebarOpen ? "translate-x-0" : "-translate-x-full"
                )}
            >
                <div className="flex flex-col h-full">
                    {/* Logo */}
                    <div className="flex items-center justify-between p-6 border-b border-[hsl(var(--border))]/30">
                        <div className="flex items-center gap-3">
                            <div className="h-12 w-12 rounded-2xl bg-gradient-to-br from-emerald-500 to-cyan-400 flex items-center justify-center shadow-xl glow">
                                <Sparkles className="h-6 w-6 text-white" />
                            </div>
                            <div>
                                <h1 className="font-bold text-xl gradient-text">Soul Sync</h1>
                                <p className="text-xs text-[hsl(var(--muted-foreground))]">Admin Panel</p>
                            </div>
                        </div>
                        <Button
                            variant="ghost"
                            size="icon"
                            className="lg:hidden"
                            onClick={() => setSidebarOpen(false)}
                        >
                            <X className="h-5 w-5" />
                        </Button>
                    </div>

                    {/* Navigation */}
                    <nav className="flex-1 p-4 space-y-1.5 overflow-y-auto">
                        {navItems.map((item) => {
                            const Icon = item.icon
                            return (
                                <NavLink
                                    key={item.href}
                                    to={item.href}
                                    onClick={() => setSidebarOpen(false)}
                                    className={({ isActive }) =>
                                        cn(
                                            "flex items-center gap-3 px-4 py-3.5 rounded-xl text-sm font-medium transition-all duration-300",
                                            isActive
                                                ? "bg-gradient-to-r from-[hsl(var(--primary))] to-[hsl(var(--primary))]/80 text-white shadow-lg shadow-[hsl(var(--primary))]/30"
                                                : "text-[hsl(var(--muted-foreground))] hover:text-[hsl(var(--foreground))] hover:bg-[hsl(var(--muted))]/50"
                                        )
                                    }
                                    end={item.href === '/'}
                                >
                                    <Icon className="h-5 w-5" />
                                    {item.label}
                                </NavLink>
                            )
                        })}
                    </nav>

                    {/* Footer */}
                    <div className="p-4 border-t border-[hsl(var(--border))]/30">
                        <div className="flex items-center gap-3 p-4 rounded-xl glass-card">
                            <div className="h-10 w-10 rounded-full bg-gradient-to-br from-rose-500 to-pink-500 flex items-center justify-center text-white text-sm font-bold shadow-lg">
                                A
                            </div>
                            <div className="flex-1 min-w-0">
                                <p className="text-sm font-semibold truncate">Admin</p>
                                <p className="text-xs text-[hsl(var(--muted-foreground))] truncate">
                                    admin@soulsync.app
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </aside>

            {/* Main Content */}
            <div className="lg:pl-72">
                {/* Mobile Header */}
                <header className="sticky top-0 z-30 lg:hidden ultra-glass-card rounded-none border-b border-[hsl(var(--border))]/30">
                    <div className="flex items-center justify-between px-4 py-4">
                        <Button variant="ghost" size="icon" onClick={() => setSidebarOpen(true)}>
                            <Menu className="h-5 w-5" />
                        </Button>
                        <div className="flex items-center gap-2">
                            <Sparkles className="h-5 w-5 text-[hsl(var(--primary))]" />
                            <span className="font-bold gradient-text">Soul Sync</span>
                        </div>
                        <div className="w-10" />
                    </div>
                </header>

                {/* Page Content */}
                <main className="p-6 lg:p-8 min-h-screen">
                    <Outlet />
                </main>
            </div>
        </div>
    )
}
