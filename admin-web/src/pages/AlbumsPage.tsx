import { useState, useEffect, useCallback } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Disc3, Plus, Pencil, Trash2, Search, Loader2, Calendar, Globe, Lock } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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

import { albumService } from '@/services'
import { albumSchema, type Album } from '@/schemas'

export default function AlbumsPage() {
    const [searchParams, setSearchParams] = useSearchParams()
    const [albums, setAlbums] = useState<Album[]>([])
    const [filteredAlbums, setFilteredAlbums] = useState<Album[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [dialogOpen, setDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedAlbum, setSelectedAlbum] = useState<Album | null>(null)
    const [saving, setSaving] = useState(false)

    const form = useForm<Album>({
        resolver: zodResolver(albumSchema.omit({ id: true, created_at: true })),
        defaultValues: {
            name: '',
            cover_url: '',
            release_year: new Date().getFullYear(),
            is_public: true,
            song_count: 0,
        },
    })

    const loadAlbums = useCallback(async () => {
        try {
            const data = await albumService.getAll()
            setAlbums(data)
            setFilteredAlbums(data)
        } catch (error) {
            toast.error('Không thể tải danh sách album')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        loadAlbums()
    }, [loadAlbums])

    useEffect(() => {
        if (searchParams.get('action') === 'create') {
            openCreateDialog()
            setSearchParams({})
        }
    }, [searchParams, setSearchParams])

    useEffect(() => {
        const filtered = albums.filter((album) =>
            album.name.toLowerCase().includes(search.toLowerCase())
        )
        setFilteredAlbums(filtered)
    }, [search, albums])

    const openCreateDialog = () => {
        setSelectedAlbum(null)
        form.reset({
            name: '',
            cover_url: '',
            release_year: new Date().getFullYear(),
            is_public: true,
            song_count: 0,
        })
        setDialogOpen(true)
    }

    const openEditDialog = (album: Album) => {
        setSelectedAlbum(album)
        form.reset({
            name: album.name,
            cover_url: album.cover_url || '',
            release_year: album.release_year || new Date().getFullYear(),
            is_public: album.is_public ?? true,
            song_count: album.song_count || 0,
        })
        setDialogOpen(true)
    }

    const openDeleteDialog = (album: Album) => {
        setSelectedAlbum(album)
        setDeleteDialogOpen(true)
    }

    const handleSubmit = async (data: Omit<Album, 'id' | 'created_at'>) => {
        setSaving(true)
        try {
            if (selectedAlbum?.id) {
                await albumService.update(selectedAlbum.id, data)
                toast.success('Cập nhật album thành công')
            } else {
                await albumService.create(data)
                toast.success('Thêm album thành công')
            }
            setDialogOpen(false)
            loadAlbums()
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async () => {
        if (!selectedAlbum?.id) return
        try {
            await albumService.delete(selectedAlbum.id)
            toast.success('Xóa album thành công')
            setDeleteDialogOpen(false)
            loadAlbums()
        } catch (error) {
            toast.error('Không thể xóa album')
            console.error(error)
        }
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-3">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-orange-500 to-red-500 shadow-lg glow-subtle">
                        <Disc3 className="h-6 w-6 text-white" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold gradient-text">Album</h1>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">
                            Quản lý danh sách album
                        </p>
                    </div>
                </div>
                <Button onClick={openCreateDialog} className="glow-subtle">
                    <Plus className="h-4 w-4 mr-2" />
                    Thêm album
                </Button>
            </div>

            {/* Search */}
            <div className="ultra-glass-card p-4">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                    <Input
                        placeholder="Tìm kiếm album..."
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
                ) : filteredAlbums.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-orange-500/20 to-red-500/20 flex items-center justify-center">
                            <Disc3 className="h-8 w-8 text-orange-400" />
                        </div>
                        <p className="text-[hsl(var(--muted-foreground))]">
                            {search ? 'Không tìm thấy album' : 'Chưa có album nào'}
                        </p>
                        {!search && (
                            <Button onClick={openCreateDialog} variant="outline" size="sm">
                                <Plus className="h-4 w-4 mr-1" />
                                Thêm album đầu tiên
                            </Button>
                        )}
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
                        {filteredAlbums.map((album, index) => (
                            <div
                                key={album.id}
                                className="group relative"
                                style={{ animationDelay: `${index * 50}ms` }}
                            >
                                <div className="glass-card overflow-hidden hover:scale-105 transition-all duration-300">
                                    <div className="relative aspect-square">
                                        {album.cover_url ? (
                                            <img
                                                src={album.cover_url}
                                                alt={album.name}
                                                className="h-full w-full object-cover"
                                            />
                                        ) : (
                                            <div className="h-full w-full flex items-center justify-center bg-gradient-to-br from-orange-500/20 to-red-500/20">
                                                <Disc3 className="h-12 w-12 text-orange-400/50" />
                                            </div>
                                        )}

                                        {/* Public/Private Badge */}
                                        <div className="absolute top-2 right-2">
                                            <div className={`p-1.5 rounded-full backdrop-blur-md ${album.is_public ? 'bg-emerald-500/20 text-emerald-400' : 'bg-rose-500/20 text-rose-400'}`}>
                                                {album.is_public ? <Globe className="h-3 w-3" /> : <Lock className="h-3 w-3" />}
                                            </div>
                                        </div>

                                        {/* Hover Overlay */}
                                        <div className="absolute inset-0 bg-black/70 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                            <Button
                                                size="icon"
                                                variant="secondary"
                                                className="h-10 w-10"
                                                onClick={() => openEditDialog(album)}
                                            >
                                                <Pencil className="h-4 w-4" />
                                            </Button>
                                            <Button
                                                size="icon"
                                                variant="destructive"
                                                className="h-10 w-10"
                                                onClick={() => openDeleteDialog(album)}
                                            >
                                                <Trash2 className="h-4 w-4" />
                                            </Button>
                                        </div>
                                    </div>
                                    <div className="p-3">
                                        <h3 className="font-semibold text-sm truncate">{album.name}</h3>
                                        {album.release_year && (
                                            <p className="text-xs text-[hsl(var(--muted-foreground))] flex items-center gap-1 mt-1">
                                                <Calendar className="h-3 w-3" />
                                                {album.release_year}
                                            </p>
                                        )}
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
                            {selectedAlbum ? 'Chỉnh sửa album' : 'Thêm album mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-5">
                        <div className="space-y-2">
                            <Label htmlFor="name">Tên album *</Label>
                            <Input
                                id="name"
                                {...form.register('name')}
                                placeholder="Nhập tên album"
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
                                        placeholder="Kéo thả ảnh bìa album"
                                    />
                                )}
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label htmlFor="release_year">Năm phát hành</Label>
                                <Input
                                    id="release_year"
                                    type="number"
                                    {...form.register('release_year', { valueAsNumber: true })}
                                    placeholder="2024"
                                    className="h-11"
                                />
                                {form.formState.errors.release_year && (
                                    <p className="text-sm text-[hsl(var(--destructive))]">
                                        {form.formState.errors.release_year.message}
                                    </p>
                                )}
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="song_count">Số bài hát</Label>
                                <Input
                                    id="song_count"
                                    type="number"
                                    {...form.register('song_count', { valueAsNumber: true })}
                                    placeholder="0"
                                    className="h-11"
                                />
                            </div>
                        </div>

                        <div className="flex items-center gap-2">
                            <input
                                type="checkbox"
                                id="is_public"
                                {...form.register('is_public')}
                                className="h-4 w-4 rounded border-[hsl(var(--border))] bg-[hsl(var(--input))] text-[hsl(var(--primary))]"
                            />
                            <Label htmlFor="is_public" className="cursor-pointer">
                                Công khai album này
                            </Label>
                        </div>

                        <DialogFooter className="gap-2">
                            <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedAlbum ? 'Cập nhật' : 'Thêm'}
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
                            Bạn có chắc chắn muốn xóa album "{selectedAlbum?.name}"?
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
