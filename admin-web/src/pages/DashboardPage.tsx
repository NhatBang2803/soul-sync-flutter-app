import { useEffect, useState } from 'react'
import { Link } from 'react-router-dom'
import {
    Music,
    Users,
    Disc3,
    Mic2,
    ListMusic,
    Tag,
    TrendingUp,
    ArrowRight,
    Sparkles,
    Database
} from 'lucide-react'
import { statsService } from '@/services'
import { Button } from '@/components/ui/button'
import { BackupDialog } from '@/components/BackupDialog'

interface Stats {
    artists: number
    genres: number
    albums: number
    songs: number
    playlists: number
    users: number
}

const statCards = [
    { key: 'songs', label: 'Bài hát', icon: Music, color: 'from-blue-500 to-cyan-400', href: '/songs' },
    { key: 'artists', label: 'Nghệ sĩ', icon: Mic2, color: 'from-purple-500 to-pink-400', href: '/artists' },
    { key: 'albums', label: 'Album', icon: Disc3, color: 'from-orange-500 to-amber-400', href: '/albums' },
    { key: 'genres', label: 'Thể loại', icon: Tag, color: 'from-emerald-500 to-teal-400', href: '/genres' },
    { key: 'playlists', label: 'Playlist', icon: ListMusic, color: 'from-indigo-500 to-violet-400', href: '/playlists' },
    { key: 'users', label: 'Người dùng', icon: Users, color: 'from-rose-500 to-pink-400', href: '/users' },
]

export default function DashboardPage() {
    const [stats, setStats] = useState<Stats | null>(null)
    const [loading, setLoading] = useState(true)
    const [backupOpen, setBackupOpen] = useState(false)

    useEffect(() => {
        const loadStats = async () => {
            try {
                const data = await statsService.getDashboardStats()
                setStats(data)
            } catch (error) {
                console.error('Failed to load stats:', error)
            } finally {
                setLoading(false)
            }
        }
        loadStats()
    }, [])

    return (
        <div className="space-y-8 animate-fade-in">
            {/* Header */}
            <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                    <div className="p-4 rounded-2xl bg-gradient-to-br from-[hsl(var(--primary))] to-[hsl(var(--accent))] shadow-2xl glow">
                        <Sparkles className="h-8 w-8 text-white" />
                    </div>
                    <div>
                        <h1 className="text-4xl font-bold gradient-text">Dashboard</h1>
                        <p className="text-[hsl(var(--muted-foreground))] mt-1">
                            Tổng quan hệ thống Soul Sync
                        </p>
                    </div>
                </div>
                <Button variant="outline" onClick={() => setBackupOpen(true)}>
                    <Database className="h-4 w-4 mr-2" />
                    Xuất file backup
                </Button>
            </div>

            {/* Stats Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                {statCards.map((card, index) => {
                    const Icon = card.icon
                    const value = stats?.[card.key as keyof Stats] ?? 0

                    return (
                        <Link
                            key={card.key}
                            to={card.href}
                            className="group ultra-glass-card p-6 hover:scale-[1.03] transition-all duration-300"
                            style={{ animationDelay: `${index * 100}ms` }}
                        >
                            <div className="flex items-start justify-between">
                                <div className="flex-1">
                                    <p className="text-sm font-medium text-[hsl(var(--muted-foreground))] uppercase tracking-wider">
                                        {card.label}
                                    </p>
                                    <div className="mt-3">
                                        {loading ? (
                                            <div className="h-10 w-20 rounded-lg animate-shimmer" />
                                        ) : (
                                            <p className="text-4xl font-bold tracking-tight">
                                                {value.toLocaleString()}
                                            </p>
                                        )}
                                    </div>
                                </div>
                                <div className={`p-4 rounded-2xl bg-gradient-to-br ${card.color} shadow-lg group-hover:scale-110 transition-transform`}>
                                    <Icon className="h-7 w-7 text-white" />
                                </div>
                            </div>
                            <div className="flex items-center gap-1.5 mt-5 text-sm text-[hsl(var(--muted-foreground))] group-hover:text-[hsl(var(--primary))] transition-colors">
                                <span>Xem chi tiết</span>
                                <ArrowRight className="h-4 w-4 group-hover:translate-x-1 transition-transform" />
                            </div>
                        </Link>
                    )
                })}
            </div>

            {/* Quick Actions */}
            <div className="ultra-glass-card p-8">
                <div className="flex items-center gap-3 mb-6">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-[hsl(var(--primary))] to-[hsl(var(--accent))] shadow-lg">
                        <TrendingUp className="h-5 w-5 text-white" />
                    </div>
                    <div>
                        <h2 className="text-xl font-bold">Thao tác nhanh</h2>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">Tạo mới nội dung</p>
                    </div>
                </div>
                <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                    {[
                        { href: '/songs?action=create', icon: Music, label: 'Thêm bài hát', color: 'from-blue-500 to-cyan-400' },
                        { href: '/artists?action=create', icon: Mic2, label: 'Thêm nghệ sĩ', color: 'from-purple-500 to-pink-400' },
                        { href: '/albums?action=create', icon: Disc3, label: 'Thêm album', color: 'from-orange-500 to-amber-400' },
                        { href: '/genres?action=create', icon: Tag, label: 'Thêm thể loại', color: 'from-emerald-500 to-teal-400' },
                    ].map((action, index) => (
                        <Link
                            key={action.href}
                            to={action.href}
                            className="group glass-card p-5 text-center hover:scale-105 transition-all duration-300"
                            style={{ animationDelay: `${(index + 6) * 100}ms` }}
                        >
                            <div className={`h-14 w-14 mx-auto rounded-2xl bg-gradient-to-br ${action.color} flex items-center justify-center shadow-lg group-hover:scale-110 transition-transform`}>
                                <action.icon className="h-7 w-7 text-white" />
                            </div>
                            <span className="block mt-3 text-sm font-medium">{action.label}</span>
                        </Link>
                    ))}
                </div>
            </div>

            {/* Footer Note */}
            <div className="glass-card p-4 text-center">
                <p className="text-sm text-[hsl(var(--muted-foreground))]">
                    💡 <span className="font-medium">Tip:</span> Kéo thả file để upload ảnh và audio trực tiếp lên Cloudinary
                </p>
            </div>

            {/* Backup Dialog */}
            <BackupDialog open={backupOpen} onOpenChange={setBackupOpen} />
        </div>
    )
}
