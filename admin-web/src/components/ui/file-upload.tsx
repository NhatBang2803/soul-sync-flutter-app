import * as React from 'react'
import { useRef, useState } from 'react'
import { Upload, X, Loader2, Check, Image, Music, FileAudio } from 'lucide-react'
import { cn } from '@/lib/utils'
import { uploadToCloudinary, getFileType } from '@/lib/cloudinary'
import { Button } from './button'

interface FileUploadProps {
    value?: string
    onChange: (url: string) => void
    accept?: string
    type?: 'image' | 'audio'
    className?: string
    placeholder?: string
}

export function FileUpload({
    value,
    onChange,
    accept,
    type = 'image',
    className,
    placeholder,
}: FileUploadProps) {
    const inputRef = useRef<HTMLInputElement>(null)
    const [uploading, setUploading] = useState(false)
    const [progress, setProgress] = useState(0)
    const [error, setError] = useState<string | null>(null)
    const [dragActive, setDragActive] = useState(false)

    const defaultAccept = type === 'image'
        ? 'image/png,image/jpeg,image/webp,image/gif'
        : 'audio/mpeg,audio/wav,audio/ogg,audio/mp3'

    const handleFile = async (file: File) => {
        setError(null)
        setUploading(true)
        setProgress(0)

        try {
            const resourceType = getFileType(file)
            const result = await uploadToCloudinary(file, resourceType, setProgress)
            onChange(result.secure_url)
        } catch (err) {
            setError('Upload thất bại. Vui lòng thử lại.')
            console.error(err)
        } finally {
            setUploading(false)
        }
    }

    const handleChange = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0]
        if (file) handleFile(file)
    }

    const handleDrag = (e: React.DragEvent) => {
        e.preventDefault()
        e.stopPropagation()
        if (e.type === 'dragenter' || e.type === 'dragover') {
            setDragActive(true)
        } else if (e.type === 'dragleave') {
            setDragActive(false)
        }
    }

    const handleDrop = (e: React.DragEvent) => {
        e.preventDefault()
        e.stopPropagation()
        setDragActive(false)
        const file = e.dataTransfer.files?.[0]
        if (file) handleFile(file)
    }

    const handleClear = () => {
        onChange('')
        if (inputRef.current) inputRef.current.value = ''
    }

    const Icon = type === 'image' ? Image : FileAudio

    return (
        <div className={cn('space-y-2', className)}>
            <input
                ref={inputRef}
                type="file"
                accept={accept || defaultAccept}
                onChange={handleChange}
                className="hidden"
            />

            {value ? (
                <div className="relative group">
                    {type === 'image' ? (
                        <div className="relative h-32 w-full rounded-xl overflow-hidden ultra-glass-card">
                            <img
                                src={value}
                                alt="Uploaded"
                                className="h-full w-full object-cover"
                            />
                            <div className="absolute inset-0 bg-black/60 opacity-0 group-hover:opacity-100 transition-opacity flex items-center justify-center gap-2">
                                <Button
                                    type="button"
                                    size="sm"
                                    variant="secondary"
                                    onClick={() => inputRef.current?.click()}
                                >
                                    <Upload className="h-4 w-4 mr-1" />
                                    Đổi
                                </Button>
                                <Button
                                    type="button"
                                    size="sm"
                                    variant="destructive"
                                    onClick={handleClear}
                                >
                                    <X className="h-4 w-4" />
                                </Button>
                            </div>
                        </div>
                    ) : (
                        <div className="ultra-glass-card p-4 rounded-xl">
                            <div className="flex items-center gap-3">
                                <div className="h-12 w-12 rounded-lg bg-gradient-to-br from-[hsl(var(--primary))] to-[hsl(var(--accent))] flex items-center justify-center shrink-0">
                                    <Music className="h-6 w-6 text-white" />
                                </div>
                                <div className="flex-1 min-w-0">
                                    <p className="text-sm font-medium truncate">{value.split('/').pop()}</p>
                                    <p className="text-xs text-[hsl(var(--muted-foreground))]">Đã upload</p>
                                </div>
                                <div className="flex gap-1">
                                    <Button
                                        type="button"
                                        size="icon"
                                        variant="ghost"
                                        onClick={() => inputRef.current?.click()}
                                    >
                                        <Upload className="h-4 w-4" />
                                    </Button>
                                    <Button
                                        type="button"
                                        size="icon"
                                        variant="ghost"
                                        className="text-[hsl(var(--destructive))]"
                                        onClick={handleClear}
                                    >
                                        <X className="h-4 w-4" />
                                    </Button>
                                </div>
                            </div>
                            <audio src={value} controls className="w-full mt-3 h-8" />
                        </div>
                    )}
                </div>
            ) : (
                <div
                    onClick={() => !uploading && inputRef.current?.click()}
                    onDragEnter={handleDrag}
                    onDragLeave={handleDrag}
                    onDragOver={handleDrag}
                    onDrop={handleDrop}
                    className={cn(
                        'relative h-32 rounded-xl border-2 border-dashed transition-all duration-300 cursor-pointer',
                        'ultra-glass-card flex flex-col items-center justify-center gap-2',
                        dragActive
                            ? 'border-[hsl(var(--primary))] bg-[hsl(var(--primary))]/10 scale-[1.02]'
                            : 'border-[hsl(var(--border))] hover:border-[hsl(var(--primary))]/50 hover:bg-[hsl(var(--muted))]/30',
                        uploading && 'pointer-events-none'
                    )}
                >
                    {uploading ? (
                        <>
                            <div className="relative h-12 w-12">
                                <svg className="absolute inset-0 -rotate-90" viewBox="0 0 48 48">
                                    <circle
                                        cx="24"
                                        cy="24"
                                        r="20"
                                        fill="none"
                                        stroke="hsl(var(--muted))"
                                        strokeWidth="4"
                                    />
                                    <circle
                                        cx="24"
                                        cy="24"
                                        r="20"
                                        fill="none"
                                        stroke="hsl(var(--primary))"
                                        strokeWidth="4"
                                        strokeLinecap="round"
                                        strokeDasharray={`${progress * 1.26} 126`}
                                        className="transition-all duration-300"
                                    />
                                </svg>
                                <div className="absolute inset-0 flex items-center justify-center">
                                    <span className="text-xs font-medium">{progress}%</span>
                                </div>
                            </div>
                            <p className="text-sm text-[hsl(var(--muted-foreground))]">Đang upload...</p>
                        </>
                    ) : (
                        <>
                            <div className="h-12 w-12 rounded-xl bg-gradient-to-br from-[hsl(var(--primary))]/20 to-[hsl(var(--accent))]/20 flex items-center justify-center">
                                <Icon className="h-6 w-6 text-[hsl(var(--primary))]" />
                            </div>
                            <div className="text-center">
                                <p className="text-sm font-medium">
                                    {placeholder || `Kéo thả ${type === 'image' ? 'ảnh' : 'audio'} vào đây`}
                                </p>
                                <p className="text-xs text-[hsl(var(--muted-foreground))]">
                                    hoặc click để chọn file
                                </p>
                            </div>
                        </>
                    )}
                </div>
            )}

            {error && (
                <p className="text-sm text-[hsl(var(--destructive))] flex items-center gap-1">
                    <X className="h-3 w-3" />
                    {error}
                </p>
            )}
        </div>
    )
}
