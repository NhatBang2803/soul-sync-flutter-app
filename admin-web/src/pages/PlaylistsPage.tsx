import { useState, useEffect, useCallback } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { ListMusic, Plus, Pencil, Trash2, Search, Loader2, Globe, Lock } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { FileUpload } from '@/components/ui/file-upload'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from '@/components/ui/dialog'
import {
    AlertDialog,
    AlertDialogAction,
    AlertDialogCancel,
    AlertDialogContent,
    AlertDialogDescription,
    AlertDialogFooter,
    AlertDialogHeader,
    AlertDialogTitle,
} from '@/components/ui/alert-dialog'

import { playlistService } from '@/services'
import { playlistSchema, type Playlist } from '@/schemas'

export default function PlaylistsPage() {
    const [searchParams, setSearchParams] = useSearchParams()
    const [playlists, setPlaylists] = useState<Playlist[]>([])
    const [filteredPlaylists, setFilteredPlaylists] = useState<Playlist[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [dialogOpen, setDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedPlaylist, setSelectedPlaylist] = useState<Playlist | null>(null)
    const [saving, setSaving] = useState(false)

    const form = useForm<Playlist>({
        resolver: zodResolver(playlistSchema.omit({ id: true, created_at: true })),
        defaultValues: {
            name: '',
            description: '',
            cover_url: '',
            is_public: true,
        },
    })

    const loadPlaylists = useCallback(async () => {
        try {
            const data = await playlistService.getAll()
            setPlaylists(data)
            setFilteredPlaylists(data)
        } catch (error) {
            toast.error('Không thể tải danh sách playlist')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        loadPlaylists()
    }, [loadPlaylists])

    useEffect(() => {
        if (searchParams.get('action') === 'create') {
            setDialogOpen(true)
            setSearchParams({})
        }
    }, [searchParams, setSearchParams])

    useEffect(() => {
        const filtered = playlists.filter((playlist) =>
            playlist.name.toLowerCase().includes(search.toLowerCase())
        )
        setFilteredPlaylists(filtered)
    }, [search, playlists])

    const openCreateDialog = () => {
        setSelectedPlaylist(null)
        form.reset({
            name: '',
            description: '',
            cover_url: '',
            is_public: true,
        })
        setDialogOpen(true)
    }

    const openEditDialog = (playlist: Playlist) => {
        setSelectedPlaylist(playlist)
        form.reset({
            name: playlist.name,
            description: playlist.description || '',
            cover_url: playlist.cover_url || '',
            is_public: playlist.is_public ?? true,
        })
        setDialogOpen(true)
    }

    const openDeleteDialog = (playlist: Playlist) => {
        setSelectedPlaylist(playlist)
        setDeleteDialogOpen(true)
    }

    const handleSubmit = async (data: Omit<Playlist, 'id' | 'created_at'>) => {
        setSaving(true)
        try {
            if (selectedPlaylist?.id) {
                await playlistService.update(selectedPlaylist.id, data)
                toast.success('Cập nhật playlist thành công')
            } else {
                await playlistService.create(data)
                toast.success('Thêm playlist thành công')
            }
            setDialogOpen(false)
            loadPlaylists()
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async () => {
        if (!selectedPlaylist?.id) return
        try {
            await playlistService.delete(selectedPlaylist.id)
            toast.success('Xóa playlist thành công')
            setDeleteDialogOpen(false)
            loadPlaylists()
        } catch (error) {
            toast.error('Không thể xóa playlist')
            console.error(error)
        }
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-3">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-indigo-500 to-violet-500 shadow-lg glow-subtle">
                        <ListMusic className="h-6 w-6 text-white" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold gradient-text">Playlist</h1>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">
                            Quản lý danh sách phát
                        </p>
                    </div>
                </div>
                <Button onClick={openCreateDialog} className="glow-subtle">
                    <Plus className="h-4 w-4 mr-2" />
                    Thêm playlist
                </Button>
            </div>

            {/* Search */}
            <div className="ultra-glass-card p-4">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                    <Input
                        placeholder="Tìm kiếm playlist..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="pl-11 h-12 text-base"
                    />
                </div>
            </div>

            {/* Grid */}
            <div className="ultra-glass-card p-6">
                {loading ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <Loader2 className="h-10 w-10 animate-spin text-[hsl(var(--primary))]" />
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">Đang tải...</p>
                    </div>
                ) : filteredPlaylists.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-indigo-500/20 to-violet-500/20 flex items-center justify-center">
                            <ListMusic className="h-8 w-8 text-indigo-400" />
                        </div>
                        <p className="text-[hsl(var(--muted-foreground))]">
                            {search ? 'Không tìm thấy playlist' : 'Chưa có playlist nào'}
                        </p>
                        {!search && (
                            <Button onClick={openCreateDialog} variant="outline" size="sm">
                                <Plus className="h-4 w-4 mr-1" />
                                Thêm playlist đầu tiên
                            </Button>
                        )}
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
                        {filteredPlaylists.map((playlist, index) => (
                            <div
                                key={playlist.id}
                                className="group relative"
                                style={{ animationDelay: `${index * 50}ms` }}
                            >
                                <div className="glass-card overflow-hidden hover:scale-105 transition-all duration-300">
                                    <div className="relative aspect-square">
                                        {playlist.cover_url ? (
                                            <img
                                                src={playlist.cover_url}
                                                alt={playlist.name}
                                                className="h-full w-full object-cover"
                                            />
                                        ) : (
                                            <div className="h-full w-full flex items-center justify-center bg-gradient-to-br from-indigo-500/20 to-violet-500/20">
                                                <ListMusic className="h-12 w-12 text-indigo-400/50" />
                                            </div>
                                        )}

                                        {/* Public/Private Badge */}
                                        <div className="absolute top-2 right-2">
                                            <div className={`p-1.5 rounded-full backdrop-blur-md ${playlist.is_public ? 'bg-emerald-500/20 text-emerald-400' : 'bg-rose-500/20 text-rose-400'}`}>
                                                {playlist.is_public ? <Globe className="h-3 w-3" /> : <Lock className="h-3 w-3" />}
                                            </div>
                                        </div>

                                        {/* Hover Overlay */}
                                        <div className="absolute inset-0 bg-black/70 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                            <Button
                                                size="icon"
                                                variant="secondary"
                                                className="h-10 w-10"
                                                onClick={() => openEditDialog(playlist)}
                                            >
                                                <Pencil className="h-4 w-4" />
                                            </Button>
                                            <Button
                                                size="icon"
                                                variant="destructive"
                                                className="h-10 w-10"
                                                onClick={() => openDeleteDialog(playlist)}
                                            >
                                                <Trash2 className="h-4 w-4" />
                                            </Button>
                                        </div>
                                    </div>
                                    <div className="p-3">
                                        <h3 className="font-semibold text-sm truncate">{playlist.name}</h3>
                                        <p className="text-xs text-[hsl(var(--muted-foreground))] mt-1 truncate">
                                            {playlist.description || 'Không có mô tả'}
                                        </p>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {/* Create/Edit Dialog */}
            <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
                <DialogContent className="max-w-lg">
                    <DialogHeader>
                        <DialogTitle className="gradient-text text-xl">
                            {selectedPlaylist ? 'Chỉnh sửa playlist' : 'Thêm playlist mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-5">
                        <div className="space-y-2">
                            <Label htmlFor="name">Tên playlist *</Label>
                            <Input
                                id="name"
                                {...form.register('name')}
                                placeholder="Nhập tên playlist"
                                className="h-11"
                            />
                            {form.formState.errors.name && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.name.message}
                                </p>
                            )}
                        </div>

                        {/* Cover Upload */}
                        <div className="space-y-2">
                            <Label>Ảnh bìa</Label>
                            <Controller
                                name="cover_url"
                                control={form.control}
                                render={({ field }) => (
                                    <FileUpload
                                        value={field.value || ''}
                                        onChange={field.onChange}
                                        type="image"
                                        placeholder="Kéo thả ảnh bìa"
                                    />
                                )}
                            />
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="description">Mô tả</Label>
                            <Textarea
                                id="description"
                                {...form.register('description')}
                                placeholder="Nhập mô tả playlist"
                                rows={3}
                            />
                        </div>

                        <div className="flex items-center gap-2">
                            <input
                                type="checkbox"
                                id="is_public"
                                {...form.register('is_public')}
                                className="h-4 w-4 rounded border-[hsl(var(--border))] bg-[hsl(var(--input))] text-[hsl(var(--primary))]"
                            />
                            <Label htmlFor="is_public" className="cursor-pointer">
                                Công khai playlist này
                            </Label>
                        </div>

                        <DialogFooter className="gap-2">
                            <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedPlaylist ? 'Cập nhật' : 'Thêm'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>

            {/* Delete Dialog */}
            <AlertDialog open={deleteDialogOpen} onOpenChange={setDeleteDialogOpen}>
                <AlertDialogContent>
                    <AlertDialogHeader>
                        <AlertDialogTitle>Xác nhận xóa</AlertDialogTitle>
                        <AlertDialogDescription>
                            Bạn có chắc chắn muốn xóa playlist "{selectedPlaylist?.name}"?
                            Hành động này không thể hoàn tác.
                        </AlertDialogDescription>
                    </AlertDialogHeader>
                    <AlertDialogFooter>
                        <AlertDialogCancel>Hủy</AlertDialogCancel>
                        <AlertDialogAction onClick={handleDelete} className="bg-[hsl(var(--destructive))]">
                            Xóa
                        </AlertDialogAction>
                    </AlertDialogFooter>
                </AlertDialogContent>
            </AlertDialog>
        </div>
    )
}
