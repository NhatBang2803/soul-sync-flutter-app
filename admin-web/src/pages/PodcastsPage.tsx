import { useState, useEffect, useCallback } from 'react'
import { useSearchParams } from 'react-router-dom'
import { useForm, Controller } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { Podcast as PodcastIcon, Plus, Pencil, Trash2, Search, Loader2, Mic, ListMusic } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Textarea } from '@/components/ui/textarea'
import { FileUpload } from '@/components/ui/file-upload'
import {
    Select,
    SelectContent,
    SelectItem,
    SelectTrigger,
    SelectValue,
} from '@/components/ui/select'
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

import { podcastService, podcastEpisodeService } from '@/services'
import { podcastSchema, podcastEpisodeSchema, type Podcast, type PodcastEpisode } from '@/schemas'

// Helper function để format duration
function formatDuration(seconds: number): string {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60
    return `${mins}:${secs.toString().padStart(2, '0')}`
}

// Danh sách thể loại podcast cố định
const PODCAST_CATEGORIES = [
    'Giáo dục',
    'Giải trí',
    'Tin tức',
    'Kinh doanh',
    'Công nghệ',
    'Sức khỏe',
    'Thể thao',
    'Âm nhạc',
    'Phim ảnh',
    'Du lịch',
    'Ẩm thực',
    'Tâm lý',
    'Lịch sử',
    'Khoa học',
    'Nghệ thuật',
    'Trò chơi',
    'Thời trang',
    'Tài chính',
    'Khác',
]

export default function PodcastsPage() {
    const [searchParams, setSearchParams] = useSearchParams()
    const [podcasts, setPodcasts] = useState<Podcast[]>([])
    const [filteredPodcasts, setFilteredPodcasts] = useState<Podcast[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [dialogOpen, setDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedPodcast, setSelectedPodcast] = useState<Podcast | null>(null)
    const [saving, setSaving] = useState(false)

    // Episode states
    const [episodeDialogOpen, setEpisodeDialogOpen] = useState(false)
    const [episodesViewOpen, setEpisodesViewOpen] = useState(false)
    const [episodes, setEpisodes] = useState<PodcastEpisode[]>([])
    const [selectedEpisode, setSelectedEpisode] = useState<PodcastEpisode | null>(null)
    const [loadingEpisodes, setLoadingEpisodes] = useState(false)

    const form = useForm({
        resolver: zodResolver(podcastSchema.omit({ id: true, created_at: true, updated_at: true })),
        defaultValues: {
            title: '',
            host_name: '',
            description: '',
            image_url: '',
            category: 'General',
        },
    })

    const episodeForm = useForm({
        resolver: zodResolver(podcastEpisodeSchema.omit({ id: true, created_at: true, play_count: true })),
        defaultValues: {
            podcast_id: '',
            title: '',
            description: '',
            audio_url: '',
            duration: 0,
        },
    })

    const loadPodcasts = useCallback(async () => {
        try {
            const data = await podcastService.getAll()
            setPodcasts(data)
            setFilteredPodcasts(data)
        } catch (error) {
            toast.error('Không thể tải danh sách podcast')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        loadPodcasts()
    }, [loadPodcasts])

    useEffect(() => {
        if (searchParams.get('action') === 'create') {
            openCreateDialog()
            setSearchParams({})
        }
    }, [searchParams, setSearchParams])

    useEffect(() => {
        const filtered = podcasts.filter((podcast) =>
            podcast.title.toLowerCase().includes(search.toLowerCase()) ||
            podcast.host_name.toLowerCase().includes(search.toLowerCase())
        )
        setFilteredPodcasts(filtered)
    }, [search, podcasts])

    const openCreateDialog = () => {
        setSelectedPodcast(null)
        form.reset({
            title: '',
            host_name: '',
            description: '',
            image_url: '',
            category: 'General',
        })
        setDialogOpen(true)
    }

    const openEditDialog = (podcast: Podcast) => {
        setSelectedPodcast(podcast)
        form.reset({
            title: podcast.title,
            host_name: podcast.host_name,
            description: podcast.description || '',
            image_url: podcast.image_url || '',
            category: podcast.category || 'General',
        })
        setDialogOpen(true)
    }

    const openDeleteDialog = (podcast: Podcast) => {
        setSelectedPodcast(podcast)
        setDeleteDialogOpen(true)
    }

    const openEpisodesView = async (podcast: Podcast) => {
        setSelectedPodcast(podcast)
        setLoadingEpisodes(true)
        setEpisodesViewOpen(true)
        try {
            const data = await podcastService.getEpisodes(podcast.id!)
            setEpisodes(data)
        } catch (error) {
            toast.error('Không thể tải danh sách tập')
            console.error(error)
        } finally {
            setLoadingEpisodes(false)
        }
    }

    const openAddEpisodeDialog = () => {
        setSelectedEpisode(null)
        episodeForm.reset({
            podcast_id: selectedPodcast?.id || '',
            title: '',
            description: '',
            audio_url: '',
            duration: 0,
        })
        setEpisodeDialogOpen(true)
    }

    const openEditEpisodeDialog = (episode: PodcastEpisode) => {
        setSelectedEpisode(episode)
        episodeForm.reset({
            podcast_id: episode.podcast_id,
            title: episode.title,
            description: episode.description || '',
            audio_url: episode.audio_url,
            duration: episode.duration,
        })
        setEpisodeDialogOpen(true)
    }

    const handleSubmit = async (data: any) => {
        setSaving(true)
        try {
            if (selectedPodcast?.id) {
                await podcastService.update(selectedPodcast.id, data)
                toast.success('Cập nhật podcast thành công')
            } else {
                await podcastService.create(data)
                toast.success('Thêm podcast thành công')
            }
            setDialogOpen(false)
            loadPodcasts()
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async () => {
        if (!selectedPodcast?.id) return
        try {
            await podcastService.delete(selectedPodcast.id)
            toast.success('Xóa podcast thành công')
            setDeleteDialogOpen(false)
            loadPodcasts()
        } catch (error) {
            toast.error('Không thể xóa podcast')
            console.error(error)
        }
    }

    const handleEpisodeSubmit = async (data: any) => {
        setSaving(true)
        try {
            if (selectedEpisode?.id) {
                await podcastEpisodeService.update(selectedEpisode.id, data)
                toast.success('Cập nhật tập thành công')
            } else {
                await podcastEpisodeService.create(data)
                toast.success('Thêm tập thành công')
            }
            setEpisodeDialogOpen(false)
            // Reload episodes
            if (selectedPodcast?.id) {
                const newEpisodes = await podcastService.getEpisodes(selectedPodcast.id)
                setEpisodes(newEpisodes)
            }
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDeleteEpisode = async (episodeId: string) => {
        try {
            await podcastEpisodeService.delete(episodeId)
            toast.success('Xóa tập thành công')
            if (selectedPodcast?.id) {
                const newEpisodes = await podcastService.getEpisodes(selectedPodcast.id)
                setEpisodes(newEpisodes)
            }
        } catch (error) {
            toast.error('Không thể xóa tập')
            console.error(error)
        }
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-3">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-violet-500 to-purple-500 shadow-lg glow-subtle">
                        <PodcastIcon className="h-6 w-6 text-white" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold gradient-text">Podcast</h1>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">
                            Quản lý danh sách podcast và các tập
                        </p>
                    </div>
                </div>
                <Button onClick={openCreateDialog} className="glow-subtle">
                    <Plus className="h-4 w-4 mr-2" />
                    Thêm podcast
                </Button>
            </div>

            {/* Search */}
            <div className="ultra-glass-card p-4">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                    <Input
                        placeholder="Tìm kiếm podcast..."
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
                ) : filteredPodcasts.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-violet-500/20 to-purple-500/20 flex items-center justify-center">
                            <PodcastIcon className="h-8 w-8 text-violet-400" />
                        </div>
                        <p className="text-[hsl(var(--muted-foreground))]">
                            {search ? 'Không tìm thấy podcast' : 'Chưa có podcast nào'}
                        </p>
                        {!search && (
                            <Button onClick={openCreateDialog} variant="outline" size="sm">
                                <Plus className="h-4 w-4 mr-1" />
                                Thêm podcast đầu tiên
                            </Button>
                        )}
                    </div>
                ) : (
                    <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 xl:grid-cols-6 gap-4">
                        {filteredPodcasts.map((podcast, index) => (
                            <div
                                key={podcast.id}
                                className="group relative"
                                style={{ animationDelay: `${index * 50}ms` }}
                            >
                                <div className="glass-card overflow-hidden hover:scale-105 transition-all duration-300">
                                    <div className="relative aspect-square">
                                        {podcast.image_url ? (
                                            <img
                                                src={podcast.image_url}
                                                alt={podcast.title}
                                                className="h-full w-full object-cover"
                                            />
                                        ) : (
                                            <div className="h-full w-full flex items-center justify-center bg-gradient-to-br from-violet-500/20 to-purple-500/20">
                                                <PodcastIcon className="h-12 w-12 text-violet-400/50" />
                                            </div>
                                        )}

                                        {/* Hover Overlay */}
                                        <div className="absolute inset-0 bg-black/70 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                            <Button
                                                size="icon"
                                                variant="secondary"
                                                className="h-9 w-9"
                                                onClick={() => openEpisodesView(podcast)}
                                                title="Xem tập"
                                            >
                                                <ListMusic className="h-4 w-4" />
                                            </Button>
                                            <Button
                                                size="icon"
                                                variant="secondary"
                                                className="h-9 w-9"
                                                onClick={() => openEditDialog(podcast)}
                                            >
                                                <Pencil className="h-4 w-4" />
                                            </Button>
                                            <Button
                                                size="icon"
                                                variant="destructive"
                                                className="h-9 w-9"
                                                onClick={() => openDeleteDialog(podcast)}
                                            >
                                                <Trash2 className="h-4 w-4" />
                                            </Button>
                                        </div>
                                    </div>
                                    <div className="p-3">
                                        <h3 className="font-semibold text-sm truncate">{podcast.title}</h3>
                                        <p className="text-xs text-[hsl(var(--muted-foreground))] flex items-center gap-1 mt-1">
                                            <Mic className="h-3 w-3" />
                                            {podcast.host_name}
                                        </p>
                                        {podcast.category && (
                                            <span className="inline-block mt-2 text-[10px] px-2 py-0.5 rounded-full bg-violet-500/20 text-violet-400">
                                                {podcast.category}
                                            </span>
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
                            {selectedPodcast ? 'Chỉnh sửa podcast' : 'Thêm podcast mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-5">
                        <div className="space-y-2">
                            <Label htmlFor="title">Tên podcast *</Label>
                            <Input
                                id="title"
                                {...form.register('title')}
                                placeholder="Nhập tên podcast"
                                className="h-11"
                            />
                            {form.formState.errors.title && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.title.message}
                                </p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="host_name">Tên host *</Label>
                            <Input
                                id="host_name"
                                {...form.register('host_name')}
                                placeholder="Nhập tên người dẫn"
                                className="h-11"
                            />
                            {form.formState.errors.host_name && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.host_name.message}
                                </p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="description">Mô tả</Label>
                            <Textarea
                                id="description"
                                {...form.register('description')}
                                placeholder="Mô tả về podcast"
                                rows={3}
                            />
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="category">Danh mục</Label>
                            <Controller
                                name="category"
                                control={form.control}
                                render={({ field }) => (
                                    <Select
                                        value={field.value || 'Khác'}
                                        onValueChange={field.onChange}
                                    >
                                        <SelectTrigger className="h-11">
                                            <SelectValue placeholder="Chọn danh mục" />
                                        </SelectTrigger>
                                        <SelectContent>
                                            {PODCAST_CATEGORIES.map((cat) => (
                                                <SelectItem key={cat} value={cat}>
                                                    {cat}
                                                </SelectItem>
                                            ))}
                                        </SelectContent>
                                    </Select>
                                )}
                            />
                        </div>

                        {/* Cover Upload */}
                        <div className="space-y-2">
                            <Label>Ảnh bìa</Label>
                            <Controller
                                name="image_url"
                                control={form.control}
                                render={({ field }) => (
                                    <FileUpload
                                        value={field.value || ''}
                                        onChange={field.onChange}
                                        type="image"
                                        placeholder="Kéo thả ảnh bìa podcast"
                                    />
                                )}
                            />
                        </div>

                        <DialogFooter className="gap-2">
                            <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedPodcast ? 'Cập nhật' : 'Thêm'}
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
                            Bạn có chắc chắn muốn xóa podcast "{selectedPodcast?.title}"?
                            Tất cả các tập cũng sẽ bị xóa. Hành động này không thể hoàn tác.
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

            {/* Episodes View Dialog */}
            <Dialog open={episodesViewOpen} onOpenChange={setEpisodesViewOpen}>
                <DialogContent className="max-w-2xl max-h-[80vh] overflow-y-auto">
                    <DialogHeader>
                        <DialogTitle className="gradient-text text-xl flex items-center gap-2">
                            <ListMusic className="h-5 w-5" />
                            Các tập của "{selectedPodcast?.title}"
                        </DialogTitle>
                    </DialogHeader>

                    <div className="flex justify-end mb-4">
                        <Button onClick={openAddEpisodeDialog} size="sm">
                            <Plus className="h-4 w-4 mr-1" />
                            Thêm tập mới
                        </Button>
                    </div>

                    {loadingEpisodes ? (
                        <div className="flex justify-center py-8">
                            <Loader2 className="h-8 w-8 animate-spin text-[hsl(var(--primary))]" />
                        </div>
                    ) : episodes.length === 0 ? (
                        <div className="text-center py-8 text-[hsl(var(--muted-foreground))]">
                            <PodcastIcon className="h-12 w-12 mx-auto mb-2 opacity-50" />
                            <p>Chưa có tập nào</p>
                        </div>
                    ) : (
                        <div className="space-y-2">
                            {episodes.map((episode, index) => (
                                <div
                                    key={episode.id}
                                    className="glass-card p-3 flex items-center gap-3 group hover:bg-[hsl(var(--muted))]/30 transition-colors"
                                >
                                    <div className="h-10 w-10 rounded-lg bg-violet-500/20 flex items-center justify-center text-violet-400 font-bold">
                                        {index + 1}
                                    </div>
                                    <div className="flex-1 min-w-0">
                                        <h4 className="font-medium truncate">{episode.title}</h4>
                                        <p className="text-xs text-[hsl(var(--muted-foreground))]">
                                            {Math.floor(episode.duration / 60)} phút
                                            {episode.play_count > 0 && ` • ${episode.play_count} lượt nghe`}
                                        </p>
                                    </div>
                                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                                        <Button
                                            size="icon"
                                            variant="ghost"
                                            className="h-8 w-8"
                                            onClick={() => openEditEpisodeDialog(episode)}
                                        >
                                            <Pencil className="h-3.5 w-3.5" />
                                        </Button>
                                        <Button
                                            size="icon"
                                            variant="ghost"
                                            className="h-8 w-8 text-[hsl(var(--destructive))]"
                                            onClick={() => handleDeleteEpisode(episode.id!)}
                                        >
                                            <Trash2 className="h-3.5 w-3.5" />
                                        </Button>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </DialogContent>
            </Dialog>

            {/* Add/Edit Episode Dialog */}
            <Dialog open={episodeDialogOpen} onOpenChange={setEpisodeDialogOpen}>
                <DialogContent className="max-w-lg">
                    <DialogHeader>
                        <DialogTitle className="gradient-text text-xl">
                            {selectedEpisode ? 'Chỉnh sửa tập' : 'Thêm tập mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={episodeForm.handleSubmit(handleEpisodeSubmit)} className="space-y-5">
                        <input type="hidden" {...episodeForm.register('podcast_id')} />

                        <div className="space-y-2">
                            <Label htmlFor="ep_title">Tiêu đề tập *</Label>
                            <Input
                                id="ep_title"
                                {...episodeForm.register('title')}
                                placeholder="Nhập tiêu đề tập"
                                className="h-11"
                            />
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="ep_description">Mô tả</Label>
                            <Textarea
                                id="ep_description"
                                {...episodeForm.register('description')}
                                placeholder="Mô tả về tập này"
                                rows={3}
                            />
                        </div>

                        {/* Audio Upload */}
                        <div className="space-y-2">
                            <Label>File audio *</Label>
                            <Controller
                                name="audio_url"
                                control={episodeForm.control}
                                render={({ field }) => (
                                    <FileUpload
                                        value={field.value || ''}
                                        onChange={field.onChange}
                                        type="audio"
                                        placeholder="Kéo thả file audio"
                                        onUploadComplete={(result) => {
                                            if (result.duration) {
                                                episodeForm.setValue('duration', Math.round(result.duration))
                                                toast.success(`Đã cập nhật thời lượng: ${formatDuration(Math.round(result.duration))}`)
                                            }
                                        }}
                                    />
                                )}
                            />
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="ep_duration">Thời lượng (giây)</Label>
                            <Input
                                id="ep_duration"
                                type="number"
                                {...episodeForm.register('duration', { valueAsNumber: true })}
                                placeholder="Tự động tính khi upload audio"
                                className="h-11 bg-muted"
                                readOnly
                            />
                        </div>

                        <DialogFooter className="gap-2">
                            <Button type="button" variant="outline" onClick={() => setEpisodeDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedEpisode ? 'Cập nhật' : 'Thêm'}
                            </Button>
                        </DialogFooter>
                    </form>
                </DialogContent>
            </Dialog>
        </div>
    )
}
