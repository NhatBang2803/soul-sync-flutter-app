import { useState, useEffect, useCallback } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Mic2, Plus, Pencil, Trash2, Search, Loader2, Users, CheckCircle2 } from 'lucide-react'
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
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table'

import { artistService } from '@/services'
import { artistSchema, type Artist } from '@/schemas'

export default function ArtistsPage() {
    const [searchParams, setSearchParams] = useSearchParams()
    const [artists, setArtists] = useState<Artist[]>([])
    const [filteredArtists, setFilteredArtists] = useState<Artist[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [dialogOpen, setDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedArtist, setSelectedArtist] = useState<Artist | null>(null)
    const [saving, setSaving] = useState(false)

    const form = useForm<Artist>({
        resolver: zodResolver(artistSchema.omit({ id: true, created_at: true })),
        defaultValues: {
            name: '',
            image_url: '',
            bio: '',
            followers: 0,
            monthly_listeners: 0,
            is_verified: false,
        },
    })

    const loadArtists = useCallback(async () => {
        try {
            const data = await artistService.getAll()
            setArtists(data)
            setFilteredArtists(data)
        } catch (error) {
            toast.error('Không thể tải danh sách nghệ sĩ')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        loadArtists()
    }, [loadArtists])

    useEffect(() => {
        if (searchParams.get('action') === 'create') {
            openCreateDialog()
            setSearchParams({})
        }
    }, [searchParams, setSearchParams])

    useEffect(() => {
        const filtered = artists.filter((artist) =>
            artist.name.toLowerCase().includes(search.toLowerCase())
        )
        setFilteredArtists(filtered)
    }, [search, artists])

    const openCreateDialog = () => {
        setSelectedArtist(null)
        form.reset({
            name: '',
            image_url: '',
            bio: '',
            followers: 0,
            monthly_listeners: 0,
            is_verified: false,
        })
        setDialogOpen(true)
    }

    const openEditDialog = (artist: Artist) => {
        setSelectedArtist(artist)
        form.reset({
            name: artist.name,
            image_url: artist.image_url || '',
            bio: artist.bio || '',
            followers: artist.followers || 0,
            monthly_listeners: artist.monthly_listeners || 0,
            is_verified: artist.is_verified || false,
        })
        setDialogOpen(true)
    }

    const openDeleteDialog = (artist: Artist) => {
        setSelectedArtist(artist)
        setDeleteDialogOpen(true)
    }

    const handleSubmit = async (data: Omit<Artist, 'id' | 'created_at'>) => {
        setSaving(true)
        try {
            if (selectedArtist?.id) {
                await artistService.update(selectedArtist.id, data)
                toast.success('Cập nhật nghệ sĩ thành công')
            } else {
                await artistService.create(data)
                toast.success('Thêm nghệ sĩ thành công')
            }
            setDialogOpen(false)
            loadArtists()
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async () => {
        if (!selectedArtist?.id) return
        try {
            await artistService.delete(selectedArtist.id)
            toast.success('Xóa nghệ sĩ thành công')
            setDeleteDialogOpen(false)
            loadArtists()
        } catch (error) {
            toast.error('Không thể xóa nghệ sĩ')
            console.error(error)
        }
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-3">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-purple-500 to-pink-500 shadow-lg glow-accent">
                        <Mic2 className="h-6 w-6 text-white" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold gradient-text">Nghệ sĩ</h1>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">
                            Quản lý danh sách nghệ sĩ
                        </p>
                    </div>
                </div>
                <Button onClick={openCreateDialog} className="glow-subtle">
                    <Plus className="h-4 w-4 mr-2" />
                    Thêm nghệ sĩ
                </Button>
            </div>

            {/* Search */}
            <div className="ultra-glass-card p-4">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                    <Input
                        placeholder="Tìm kiếm nghệ sĩ..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="pl-11 h-12 text-base"
                    />
                </div>
            </div>

            {/* Grid View */}
            <div className="ultra-glass-card p-6">
                {loading ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <Loader2 className="h-10 w-10 animate-spin text-[hsl(var(--primary))]" />
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">Đang tải...</p>
                    </div>
                ) : filteredArtists.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <div className="h-16 w-16 rounded-full bg-gradient-to-br from-purple-500/20 to-pink-500/20 flex items-center justify-center">
                            <Mic2 className="h-8 w-8 text-purple-400" />
                        </div>
                        <p className="text-[hsl(var(--muted-foreground))]">
                            {search ? 'Không tìm thấy nghệ sĩ' : 'Chưa có nghệ sĩ nào'}
                        </p>
                        {!search && (
                            <Button onClick={openCreateDialog} variant="outline" size="sm">
                                <Plus className="h-4 w-4 mr-1" />
                                Thêm nghệ sĩ đầu tiên
                            </Button>
                        )}
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
                        {filteredArtists.map((artist, index) => (
                            <div
                                key={artist.id}
                                className="group relative"
                                style={{ animationDelay: `${index * 50}ms` }}
                            >
                                <div className="glass-card p-4 text-center hover:scale-105 transition-all duration-300 cursor-pointer">
                                    <div className="relative mx-auto h-20 w-20 rounded-full overflow-hidden mb-3 ring-2 ring-transparent group-hover:ring-[hsl(var(--primary))] transition-all">
                                        {artist.image_url ? (
                                            <img
                                                src={artist.image_url}
                                                alt={artist.name}
                                                className="h-full w-full object-cover"
                                            />
                                        ) : (
                                            <div className="h-full w-full flex items-center justify-center bg-gradient-to-br from-purple-500 to-pink-500">
                                                <span className="text-2xl font-bold text-white">
                                                    {artist.name[0]?.toUpperCase()}
                                                </span>
                                            </div>
                                        )}
                                        {artist.is_verified && (
                                            <div className="absolute bottom-0 right-0 bg-blue-500 text-white p-0.5 rounded-full ring-2 ring-white">
                                                <CheckCircle2 className="h-3 w-3" />
                                            </div>
                                        )}
                                    </div>
                                    <h3 className="font-semibold text-sm truncate flex items-center justify-center gap-1">
                                        {artist.name}
                                        {artist.is_verified && <CheckCircle2 className="h-3 w-3 text-blue-500" />}
                                    </h3>
                                    <p className="text-xs text-[hsl(var(--muted-foreground))] flex items-center justify-center gap-1 mt-1">
                                        <Users className="h-3 w-3" />
                                        {(artist.monthly_listeners || 0).toLocaleString()}
                                    </p>

                                    {/* Hover Actions */}
                                    <div className="absolute inset-0 bg-black/60 rounded-[var(--radius)] opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                        <Button
                                            size="icon"
                                            variant="secondary"
                                            className="h-9 w-9"
                                            onClick={() => openEditDialog(artist)}
                                        >
                                            <Pencil className="h-4 w-4" />
                                        </Button>
                                        <Button
                                            size="icon"
                                            variant="destructive"
                                            className="h-9 w-9"
                                            onClick={() => openDeleteDialog(artist)}
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            {/* Create/Edit Dialog */}
            <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
                <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle className="gradient-text text-xl">
                            {selectedArtist ? 'Chỉnh sửa nghệ sĩ' : 'Thêm nghệ sĩ mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-5">
                        <div className="space-y-2">
                            <Label htmlFor="name">Tên nghệ sĩ *</Label>
                            <Input
                                id="name"
                                {...form.register('name')}
                                placeholder="Nhập tên nghệ sĩ"
                                className="h-11"
                            />
                            {form.formState.errors.name && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.name.message}
                                </p>
                            )}
                        </div>

                        {/* Image Upload */}
                        <div className="space-y-2">
                            <Label>Hình ảnh</Label>
                            <Controller
                                name="image_url"
                                control={form.control}
                                render={({ field }) => (
                                    <FileUpload
                                        value={field.value || ''}
                                        onChange={field.onChange}
                                        type="image"
                                        placeholder="Kéo thả hình ảnh nghệ sĩ"
                                    />
                                )}
                            />
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="bio">Tiểu sử</Label>
                            <Textarea
                                id="bio"
                                {...form.register('bio')}
                                placeholder="Nhập tiểu sử nghệ sĩ"
                                rows={3}
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label htmlFor="followers">Người theo dõi</Label>
                                <Input
                                    id="followers"
                                    type="number"
                                    {...form.register('followers', { valueAsNumber: true })}
                                    placeholder="0"
                                    className="h-11"
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="monthly_listeners">Lượt nghe/tháng</Label>
                                <Input
                                    id="monthly_listeners"
                                    type="number"
                                    {...form.register('monthly_listeners', { valueAsNumber: true })}
                                    placeholder="0"
                                    className="h-11"
                                />
                            </div>
                        </div>

                        <div className="flex items-center gap-2">
                            <input
                                type="checkbox"
                                id="is_verified"
                                {...form.register('is_verified')}
                                className="h-4 w-4 rounded border-[hsl(var(--border))] bg-[hsl(var(--input))] text-[hsl(var(--primary))]"
                            />
                            <Label htmlFor="is_verified" className="cursor-pointer">
                                Nghệ sĩ đã xác minh
                            </Label>
                        </div>

                        <DialogFooter className="gap-2">
                            <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedArtist ? 'Cập nhật' : 'Thêm'}
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
                            Bạn có chắc chắn muốn xóa nghệ sĩ "{selectedArtist?.name}"?
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
