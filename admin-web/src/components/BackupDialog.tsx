import { useState } from 'react'
import { Download, Copy, Check, Database, Loader2 } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import {
    Dialog,
    DialogContent,
    DialogHeader,
    DialogTitle,
    DialogFooter,
} from '@/components/ui/dialog'
import { supabase } from '@/lib/supabase'

interface BackupDialogProps {
    open: boolean
    onOpenChange: (open: boolean) => void
}

const TABLES = [
    { name: 'artists', label: 'Nghệ sĩ' },
    { name: 'genres', label: 'Thể loại' },
    { name: 'albums', label: 'Album' },
    { name: 'songs', label: 'Bài hát' },
    { name: 'playlists', label: 'Playlist' },
    { name: 'song_artists', label: 'Song ↔ Artist' },
    { name: 'album_artists', label: 'Album ↔ Artist' },
    { name: 'album_songs', label: 'Album ↔ Song' },
    { name: 'song_genres', label: 'Song ↔ Genre' },
]

function formatSQLValue(value: unknown): string {
    if (value === null || value === undefined) return 'NULL'
    if (typeof value === 'boolean') return value ? 'TRUE' : 'FALSE'
    if (typeof value === 'number') return String(value)
    if (typeof value === 'string') {
        // Escape single quotes
        const escaped = value.replace(/'/g, "''")
        return `'${escaped}'`
    }
    if (value instanceof Date) return `'${value.toISOString()}'`
    // For arrays or objects, use JSON
    return `'${JSON.stringify(value).replace(/'/g, "''")}'`
}

function generateInsertSQL(tableName: string, rows: Record<string, unknown>[]): string {
    if (rows.length === 0) return `-- No data in ${tableName}\n`

    const columns = Object.keys(rows[0])
    const lines = rows.map((row) => {
        const values = columns.map((col) => formatSQLValue(row[col]))
        return `  (${values.join(', ')})`
    })

    return `-- ${tableName}\nINSERT INTO ${tableName} (${columns.join(', ')}) VALUES\n${lines.join(',\n')}\nON CONFLICT DO NOTHING;\n\n`
}

export function BackupDialog({ open, onOpenChange }: BackupDialogProps) {
    const [loading, setLoading] = useState(false)
    const [sql, setSQL] = useState('')
    const [copied, setCopied] = useState(false)

    const generateBackup = async () => {
        setLoading(true)
        setSQL('')

        try {
            let output = `-- Soul Sync Database Backup\n-- Generated at: ${new Date().toISOString()}\n\n`

            for (const table of TABLES) {
                const { data, error } = await supabase
                    .from(table.name)
                    .select('*')

                if (error) {
                    output += `-- Error loading ${table.name}: ${error.message}\n\n`
                    continue
                }

                output += generateInsertSQL(table.name, data || [])
            }

            setSQL(output)
            toast.success('Đã tạo file backup thành công')
        } catch (error) {
            toast.error('Không thể tạo backup')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }

    const copyToClipboard = async () => {
        try {
            await navigator.clipboard.writeText(sql)
            setCopied(true)
            toast.success('Đã sao chép vào clipboard')
            setTimeout(() => setCopied(false), 2000)
        } catch {
            toast.error('Không thể sao chép')
        }
    }

    const downloadFile = () => {
        const blob = new Blob([sql], { type: 'text/sql' })
        const url = URL.createObjectURL(blob)
        const a = document.createElement('a')
        a.href = url
        a.download = `soul-sync-backup-${new Date().toISOString().split('T')[0]}.sql`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)
        toast.success('Đã tải file backup')
    }

    return (
        <Dialog open={open} onOpenChange={onOpenChange}>
            <DialogContent className="max-w-2xl max-h-[80vh] overflow-hidden flex flex-col">
                <DialogHeader>
                    <DialogTitle className="flex items-center gap-2">
                        <Database className="h-5 w-5" />
                        Xuất file backup
                    </DialogTitle>
                </DialogHeader>

                <div className="flex-1 overflow-hidden flex flex-col gap-4">
                    <p className="text-sm text-[hsl(var(--muted-foreground))]">
                        Xuất dữ liệu dưới dạng SQL INSERT để backup hoặc chuyển sang database khác.
                    </p>

                    {!sql ? (
                        <div className="flex items-center justify-center py-12">
                            <Button onClick={generateBackup} disabled={loading} size="lg">
                                {loading ? (
                                    <>
                                        <Loader2 className="h-4 w-4 mr-2 animate-spin" />
                                        Đang tạo backup...
                                    </>
                                ) : (
                                    <>
                                        <Database className="h-4 w-4 mr-2" />
                                        Tạo file backup
                                    </>
                                )}
                            </Button>
                        </div>
                    ) : (
                        <>
                            <div className="flex-1 min-h-0 overflow-hidden rounded-lg border">
                                <pre className="h-full overflow-auto p-4 text-xs font-mono bg-[hsl(var(--muted))]/50">
                                    {sql}
                                </pre>
                            </div>

                            <DialogFooter className="gap-2">
                                <Button variant="outline" onClick={copyToClipboard}>
                                    {copied ? (
                                        <>
                                            <Check className="h-4 w-4 mr-2" />
                                            Đã sao chép
                                        </>
                                    ) : (
                                        <>
                                            <Copy className="h-4 w-4 mr-2" />
                                            Sao chép
                                        </>
                                    )}
                                </Button>
                                <Button onClick={downloadFile}>
                                    <Download className="h-4 w-4 mr-2" />
                                    Tải xuống .sql
                                </Button>
                            </DialogFooter>
                        </>
                    )}
                </div>
            </DialogContent>
        </Dialog>
    )
}
