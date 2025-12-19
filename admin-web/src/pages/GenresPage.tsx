import { useState, useEffect, useCallback } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Tag, Plus, Pencil, Trash2, Search, Loader2 } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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

import { genreService } from '@/services'
import { genreSchema, type Genre } from '@/schemas'

export default function GenresPage() {
    const [searchParams, setSearchParams] = useSearchParams()
    const [genres, setGenres] = useState<Genre[]>([])
    const [filteredGenres, setFilteredGenres] = useState<Genre[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [dialogOpen, setDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedGenre, setSelectedGenre] = useState<Genre | null>(null)
    const [saving, setSaving] = useState(false)

    const form = useForm<Genre>({
        resolver: zodResolver(genreSchema.omit({ id: true, created_at: true })),
        defaultValues: {
            name: '',
            display_name: '',
            color: '#6366F1',
        },
    })

    const loadGenres = useCallback(async () => {
        try {
            const data = await genreService.getAll()
            setGenres(data)
            setFilteredGenres(data)
        } catch (error) {
            toast.error('Không thể tải danh sách thể loại')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        loadGenres()
    }, [loadGenres])

    useEffect(() => {
        if (searchParams.get('action') === 'create') {
            setDialogOpen(true)
            setSearchParams({})
        }
    }, [searchParams, setSearchParams])

    useEffect(() => {
        const filtered = genres.filter((genre) =>
            genre.display_name.toLowerCase().includes(search.toLowerCase()) ||
            genre.name.toLowerCase().includes(search.toLowerCase())
        )
        setFilteredGenres(filtered)
    }, [search, genres])

    const openCreateDialog = () => {
        setSelectedGenre(null)
        form.reset({
            name: '',
            display_name: '',
            color: '#6366F1',
        })
        setDialogOpen(true)
    }

    const openEditDialog = (genre: Genre) => {
        setSelectedGenre(genre)
        form.reset({
            name: genre.name,
            display_name: genre.display_name,
            color: genre.color || '#6366F1',
        })
        setDialogOpen(true)
    }

    const openDeleteDialog = (genre: Genre) => {
        setSelectedGenre(genre)
        setDeleteDialogOpen(true)
    }

    const handleSubmit = async (data: Omit<Genre, 'id' | 'created_at'>) => {
        setSaving(true)
        try {
            if (selectedGenre?.id) {
                await genreService.update(selectedGenre.id, data)
                toast.success('Cập nhật thể loại thành công')
            } else {
                await genreService.create(data)
                toast.success('Thêm thể loại thành công')
            }
            setDialogOpen(false)
            loadGenres()
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async () => {
        if (!selectedGenre?.id) return
        try {
            await genreService.delete(selectedGenre.id)
            toast.success('Xóa thể loại thành công')
            setDeleteDialogOpen(false)
            loadGenres()
        } catch (error) {
            toast.error('Không thể xóa thể loại')
            console.error(error)
        }
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-3">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-emerald-500 to-cyan-500 shadow-lg glow-subtle">
                        <Tag className="h-6 w-6 text-white" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold gradient-text">Thể loại</h1>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">
                            Quản lý danh sách thể loại nhạc
                        </p>
                    </div>
                </div>
                <Button onClick={openCreateDialog} className="glow-subtle">
                    <Plus className="h-4 w-4 mr-2" />
                    Thêm thể loại
                </Button>
            </div>

            {/* Search */}
            <div className="ultra-glass-card p-4">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                    <Input
                        placeholder="Tìm kiếm thể loại..."
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
                ) : filteredGenres.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-emerald-500/20 to-cyan-500/20 flex items-center justify-center">
                            <Tag className="h-8 w-8 text-emerald-400" />
                        </div>
                        <p className="text-[hsl(var(--muted-foreground))]">
                            {search ? 'Không tìm thấy thể loại' : 'Chưa có thể loại nào'}
                        </p>
                        {!search && (
                            <Button onClick={openCreateDialog} variant="outline" size="sm">
                                <Plus className="h-4 w-4 mr-1" />
                                Thêm thể loại đầu tiên
                            </Button>
                        )}
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
                        {filteredGenres.map((genre, index) => (
                            <div
                                key={genre.id}
                                className="group relative rounded-xl overflow-hidden aspect-[1.5/1] cursor-pointer shadow-lg"
                                style={{
                                    animationDelay: `${index * 50}ms`,
                                    backgroundColor: genre.color || '#6366F1'
                                }}
                            >
                                {/* Overlay */}
                                <div className="absolute inset-0 bg-gradient-to-br from-black/10 to-black/30 group-hover:to-black/50 transition-colors" />

                                {/* Content */}
                                <div className="absolute inset-0 p-4 flex flex-col justify-end">
                                    <h3 className="font-bold text-lg text-white drop-shadow-md">{genre.display_name}</h3>
                                    <p className="text-xs text-white/80">{genre.name}</p>
                                </div>

                                {/* Hover Actions */}
                                <div className="absolute top-2 right-2 flex gap-1.5 opacity-0 group-hover:opacity-100 transition-all duration-300 translate-y-2 group-hover:translate-y-0">
                                    <Button
                                        variant="secondary"
                                        size="icon"
                                        className="h-8 w-8 backdrop-blur-sm bg-black/20 hover:bg-black/40 text-white border-0"
                                        onClick={() => openEditDialog(genre)}
                                    >
                                        <Pencil className="h-3.5 w-3.5" />
                                    </Button>
                                    <Button
                                        variant="destructive"
                                        size="icon"
                                        className="h-8 w-8 backdrop-blur-sm bg-black/20 hover:bg-red-500 text-white border-0"
                                        onClick={() => openDeleteDialog(genre)}
                                    >
                                        <Trash2 className="h-3.5 w-3.5" />
                                    </Button>
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
                            {selectedGenre ? 'Chỉnh sửa thể loại' : 'Thêm thể loại mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-5">
                        <div className="space-y-2">
                            <Label htmlFor="display_name">Tên hiển thị *</Label>
                            <Input
                                id="display_name"
                                {...form.register('display_name')}
                                placeholder="Ví dụ: Rap/Hip-hop"
                                className="h-11"
                            />
                            {form.formState.errors.display_name && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.display_name.message}
                                </p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="name">Mã thể loại *</Label>
                            <Input
                                id="name"
                                {...form.register('name')}
                                placeholder="Ví dụ: rap"
                                className="h-11 font-mono"
                            />
                            <p className="text-xs text-[hsl(var(--muted-foreground))]">
                                Dùng để định danh, viết thường không dấu
                            </p>
                            {form.formState.errors.name && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.name.message}
                                </p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="color">Màu sắc</Label>
                            <div className="flex gap-3">
                                <Input
                                    id="color"
                                    type="color"
                                    {...form.register('color')}
                                    className="w-16 h-11 p-1 cursor-pointer"
                                />
                                <Input
                                    {...form.register('color')}
                                    placeholder="#6366F1"
                                    className="flex-1 h-11 font-mono"
                                />
                            </div>
                            {form.formState.errors.color && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.color.message}
                                </p>
                            )}
                        </div>

                        <DialogFooter className="gap-2">
                            <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedGenre ? 'Cập nhật' : 'Thêm'}
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
                            Bạn có chắc chắn muốn xóa thể loại "{selectedGenre?.display_name}"?
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
