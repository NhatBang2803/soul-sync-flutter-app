import { useState, useEffect, useCallback } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useForm, Controller } from 'react-hook-form'
import { Music, Plus, Pencil, Trash2, Search, Loader2, Clock, Play, Mic2 } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { FileUpload } from '@/components/ui/file-upload'
import { MultiSelect, type Option } from '@/components/ui/multi-select'
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

import { songService, artistService } from '@/services'
import type { Song, Artist } from '@/schemas'

interface SongFormData {
    title: string
    audio_url: string
    cover_url: string
    duration: number
    play_count: number
}

function formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
}

export default function SongsPage() {
    const [searchParams, setSearchParams] = useSearchParams()
    const [songs, setSongs] = useState<Song[]>([])
    const [filteredSongs, setFilteredSongs] = useState<Song[]>([])
    const [artists, setArtists] = useState<Artist[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [dialogOpen, setDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedSong, setSelectedSong] = useState<Song | null>(null)
    const [selectedArtistIds, setSelectedArtistIds] = useState<string[]>([])
    const [saving, setSaving] = useState(false)

    const form = useForm<SongFormData>({
        defaultValues: {
            title: '',
            audio_url: '',
            cover_url: '',
            duration: 0,
            play_count: 0,
        },
    })

    // Convert artists to options for MultiSelect
    const artistOptions: Option[] = artists.map((artist) => ({
        value: artist.id!,
        label: artist.name,
        avatar: artist.image_url || undefined,
    }))

    const loadData = useCallback(async () => {
        try {
            const [songsData, artistsData] = await Promise.all([
                songService.getAll(),
                artistService.getAll(),
            ])
            setSongs(songsData)
            setFilteredSongs(songsData)
            setArtists(artistsData)
        } catch (error) {
            toast.error('Không thể tải dữ liệu')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        loadData()
    }, [loadData])

    useEffect(() => {
        if (searchParams.get('action') === 'create') {
            openCreateDialog()
            setSearchParams({})
        }
    }, [searchParams, setSearchParams])

    useEffect(() => {
        const filtered = songs.filter((song) =>
            song.title.toLowerCase().includes(search.toLowerCase())
        )
        setFilteredSongs(filtered)
    }, [search, songs])

    const openCreateDialog = () => {
        setSelectedSong(null)
        setSelectedArtistIds([])
        form.reset({
            title: '',
            audio_url: '',
            cover_url: '',
            duration: 0,
            play_count: 0,
        })
        setDialogOpen(true)
    }

    const openEditDialog = async (song: Song) => {
        setSelectedSong(song)
        form.reset({
            title: song.title,
            audio_url: song.audio_url,
            cover_url: song.cover_url || '',
            duration: song.duration || 0,
            play_count: song.play_count || 0,
        })

        // Load existing artists for this song
        try {
            const songArtists = await songService.getArtists(song.id!)
            setSelectedArtistIds(songArtists?.map((sa) => sa.artist_id) || [])
        } catch (error) {
            console.error('Failed to load song artists:', error)
            setSelectedArtistIds([])
        }

        setDialogOpen(true)
    }

    const openDeleteDialog = (song: Song) => {
        setSelectedSong(song)
        setDeleteDialogOpen(true)
    }

    const handleSubmit = async (data: SongFormData) => {
        setSaving(true)
        try {
            let songId: string

            if (selectedSong?.id) {
                await songService.update(selectedSong.id, data)
                songId = selectedSong.id
                toast.success('Cập nhật bài hát thành công')
            } else {
                const newSong = await songService.create(data)
                songId = newSong.id!
                toast.success('Thêm bài hát thành công')
            }

            // Update artists for this song
            if (selectedArtistIds.length >= 0) { // Allow clearing artists if needed, changed > 0 to >= 0 or logic handled by setArtists
                // Actually setArtists handles deletion. If array empty, it deletes all. so logic stands.
                await songService.setArtists(songId, selectedArtistIds)
            }

            setDialogOpen(false)
            loadData()
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async () => {
        if (!selectedSong?.id) return
        try {
            await songService.delete(selectedSong.id)
            toast.success('Xóa bài hát thành công')
            setDeleteDialogOpen(false)
            loadData()
        } catch (error) {
            toast.error('Không thể xóa bài hát')
            console.error(error)
        }
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-3">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-emerald-500 to-cyan-500 shadow-lg glow-subtle">
                        <Music className="h-6 w-6 text-white" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold gradient-text">Bài hát</h1>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">
                            Quản lý danh sách bài hát
                        </p>
                    </div>
                </div>
                <Button onClick={openCreateDialog} className="glow-subtle">
                    <Plus className="h-4 w-4 mr-2" />
                    Thêm bài hát
                </Button>
            </div>

            {/* Search */}
            <div className="ultra-glass-card p-4">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                    <Input
                        placeholder="Tìm kiếm bài hát..."
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        className="pl-11 h-12 text-base"
                    />
                </div>
            </div>

            {/* Table */}
            <div className="ultra-glass-card overflow-hidden">
                {loading ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <Loader2 className="h-10 w-10 animate-spin text-[hsl(var(--primary))]" />
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">Đang tải...</p>
                    </div>
                ) : filteredSongs.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-[hsl(var(--muted))] to-[hsl(var(--background))] flex items-center justify-center">
                            <Music className="h-8 w-8 text-[hsl(var(--muted-foreground))]" />
                        </div>
                        <p className="text-[hsl(var(--muted-foreground))]">
                            {search ? 'Không tìm thấy bài hát' : 'Chưa có bài hát nào'}
                        </p>
                        {!search && (
                            <Button onClick={openCreateDialog} variant="outline" size="sm">
                                <Plus className="h-4 w-4 mr-1" />
                                Thêm bài hát đầu tiên
                            </Button>
                        )}
                    </div>
                ) : (
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead className="w-16"></TableHead>
                                <TableHead>Tiêu đề</TableHead>
                                <TableHead className="hidden md:table-cell">Thời lượng</TableHead>
                                <TableHead className="hidden sm:table-cell">Lượt phát</TableHead>
                                <TableHead className="text-right">Thao tác</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {filteredSongs.map((song, index) => (
                                <TableRow key={song.id} className="group" style={{ animationDelay: `${index * 50}ms` }}>
                                    <TableCell>
                                        <div className="relative h-12 w-12 rounded-lg bg-[hsl(var(--muted))] overflow-hidden group-hover:scale-105 transition-transform">
                                            {song.cover_url ? (
                                                <img
                                                    src={song.cover_url}
                                                    alt={song.title}
                                                    className="h-full w-full object-cover"
                                                />
                                            ) : (
                                                <div className="h-full w-full flex items-center justify-center bg-gradient-to-br from-emerald-500/20 to-cyan-500/20">
                                                    <Music className="h-5 w-5 text-emerald-400" />
                                                </div>
                                            )}
                                            <div className="absolute inset-0 bg-black/40 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center">
                                                <Play className="h-5 w-5 text-white" fill="white" />
                                            </div>
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        <p className="font-medium">{song.title}</p>
                                        <p className="text-xs text-[hsl(var(--muted-foreground))] sm:hidden">
                                            {formatDuration(song.duration || 0)} • {(song.play_count || 0).toLocaleString()} lượt
                                        </p>
                                    </TableCell>
                                    <TableCell className="hidden md:table-cell">
                                        <div className="flex items-center gap-1.5 text-[hsl(var(--muted-foreground))]">
                                            <Clock className="h-3.5 w-3.5" />
                                            {formatDuration(song.duration || 0)}
                                        </div>
                                    </TableCell>
                                    <TableCell className="hidden sm:table-cell">
                                        <span className="text-[hsl(var(--muted-foreground))]">
                                            {(song.play_count || 0).toLocaleString()}
                                        </span>
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <div className="flex items-center justify-end gap-1">
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                onClick={() => openEditDialog(song)}
                                                className="h-9 w-9 opacity-60 group-hover:opacity-100"
                                            >
                                                <Pencil className="h-4 w-4" />
                                            </Button>
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                onClick={() => openDeleteDialog(song)}
                                                className="h-9 w-9 opacity-60 group-hover:opacity-100 text-[hsl(var(--destructive))] hover:text-[hsl(var(--destructive))]"
                                            >
                                                <Trash2 className="h-4 w-4" />
                                            </Button>
                                        </div>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                )}
            </div>

            {/* Create/Edit Dialog */}
            <Dialog open={dialogOpen} onOpenChange={setDialogOpen}>
                <DialogContent className="max-w-lg max-h-[90vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle className="gradient-text text-xl">
                            {selectedSong ? 'Chỉnh sửa bài hát' : 'Thêm bài hát mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-5">
                        <div className="space-y-2">
                            <Label htmlFor="title">Tiêu đề *</Label>
                            <Input
                                id="title"
                                {...form.register('title')}
                                placeholder="Nhập tiêu đề bài hát"
                                className="h-11"
                            />
                            {form.formState.errors.title && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.title.message}
                                </p>
                            )}
                        </div>

                        {/* Artist Selection */}
                        <div className="space-y-2">
                            <Label className="flex items-center gap-2">
                                <Mic2 className="h-4 w-4" />
                                Ca sĩ / Nghệ sĩ
                            </Label>
                            <MultiSelect
                                options={artistOptions}
                                value={selectedArtistIds}
                                onChange={setSelectedArtistIds}
                                placeholder="Chọn một hoặc nhiều ca sĩ..."
                            />
                            <p className="text-xs text-[hsl(var(--muted-foreground))]">
                                Có thể chọn nhiều ca sĩ cho một bài hát
                            </p>
                        </div>

                        {/* Audio Upload */}
                        <div className="space-y-2">
                            <Label>File audio *</Label>
                            <Controller
                                name="audio_url"
                                control={form.control}
                                render={({ field }) => (
                                    <FileUpload
                                        value={field.value}
                                        onChange={field.onChange}
                                        type="audio"
                                        placeholder="Kéo thả file audio (MP3, WAV...)"
                                    />
                                )}
                            />
                            {form.formState.errors.audio_url && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.audio_url.message}
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
                                        placeholder="Kéo thả ảnh bìa (PNG, JPG...)"
                                    />
                                )}
                            />
                        </div>

                        <div className="grid grid-cols-2 gap-4">
                            <div className="space-y-2">
                                <Label htmlFor="duration">Thời lượng (giây)</Label>
                                <Input
                                    id="duration"
                                    type="number"
                                    {...form.register('duration', { valueAsNumber: true })}
                                    placeholder="180"
                                    className="h-11"
                                />
                            </div>
                            <div className="space-y-2">
                                <Label htmlFor="play_count">Lượt phát</Label>
                                <Input
                                    id="play_count"
                                    type="number"
                                    {...form.register('play_count', { valueAsNumber: true })}
                                    placeholder="0"
                                    className="h-11"
                                />
                            </div>
                        </div>

                        <DialogFooter className="gap-2">
                            <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedSong ? 'Cập nhật' : 'Thêm'}
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
                            Bạn có chắc chắn muốn xóa bài hát "{selectedSong?.title}"?
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
