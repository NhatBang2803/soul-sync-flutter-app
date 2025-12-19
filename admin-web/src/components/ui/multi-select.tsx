import * as React from 'react'
import { X, Check, ChevronsUpDown, Search } from 'lucide-react'
import { cn } from '@/lib/utils'

export interface Option {
    value: string
    label: string
    avatar?: string
}

interface MultiSelectProps {
    options: Option[]
    value: string[]
    onChange: (value: string[]) => void
    placeholder?: string
    loading?: boolean
    className?: string
}

export function MultiSelect({
    options,
    value,
    onChange,
    placeholder = 'Chọn...',
    loading = false,
    className,
}: MultiSelectProps) {
    const [open, setOpen] = React.useState(false)
    const [search, setSearch] = React.useState('')
    const containerRef = React.useRef<HTMLDivElement>(null)

    const selectedOptions = options.filter((opt) => value.includes(opt.value))
    const filteredOptions = options.filter(
        (opt) =>
            opt.label.toLowerCase().includes(search.toLowerCase()) &&
            !value.includes(opt.value)
    )

    const handleSelect = (optionValue: string) => {
        if (value.includes(optionValue)) {
            onChange(value.filter((v) => v !== optionValue))
        } else {
            onChange([...value, optionValue])
        }
    }

    const handleRemove = (optionValue: string, e: React.MouseEvent) => {
        e.stopPropagation()
        onChange(value.filter((v) => v !== optionValue))
    }

    // Close dropdown when clicking outside
    React.useEffect(() => {
        const handleClickOutside = (e: MouseEvent) => {
            if (containerRef.current && !containerRef.current.contains(e.target as Node)) {
                setOpen(false)
            }
        }
        document.addEventListener('mousedown', handleClickOutside)
        return () => document.removeEventListener('mousedown', handleClickOutside)
    }, [])

    return (
        <div ref={containerRef} className={cn('relative', className)}>
            {/* Trigger */}
            <div
                onClick={() => setOpen(!open)}
                className={cn(
                    'min-h-[44px] w-full rounded-lg border border-[hsl(var(--border))] bg-[hsl(var(--input))] px-3 py-2 cursor-pointer transition-all',
                    'hover:border-[hsl(var(--primary))]/50',
                    open && 'border-[hsl(var(--primary))] ring-2 ring-[hsl(var(--primary))]/20'
                )}
            >
                <div className="flex flex-wrap gap-1.5">
                    {selectedOptions.length === 0 ? (
                        <span className="text-[hsl(var(--muted-foreground))] text-sm py-0.5">
                            {placeholder}
                        </span>
                    ) : (
                        selectedOptions.map((opt) => (
                            <span
                                key={opt.value}
                                className="inline-flex items-center gap-1 px-2 py-1 rounded-md bg-[hsl(var(--secondary))] text-sm"
                            >
                                {opt.avatar && (
                                    <img
                                        src={opt.avatar}
                                        alt={opt.label}
                                        className="h-4 w-4 rounded-full object-cover"
                                    />
                                )}
                                {opt.label}
                                <button
                                    type="button"
                                    onClick={(e) => handleRemove(opt.value, e)}
                                    className="ml-1 hover:text-[hsl(var(--destructive))] transition-colors"
                                >
                                    <X className="h-3 w-3" />
                                </button>
                            </span>
                        ))
                    )}
                </div>
                <ChevronsUpDown className="absolute right-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
            </div>

            {/* Dropdown */}
            {open && (
                <div className="absolute z-50 w-full mt-2 ultra-glass-card rounded-xl overflow-hidden shadow-2xl">
                    {/* Search */}
                    <div className="p-2 border-b border-[hsl(var(--border))]/30">
                        <div className="relative">
                            <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                            <input
                                type="text"
                                placeholder="Tìm kiếm..."
                                value={search}
                                onChange={(e) => setSearch(e.target.value)}
                                className="w-full h-9 pl-9 pr-3 rounded-lg bg-[hsl(var(--background))] border border-[hsl(var(--border))] text-sm focus:outline-none focus:border-[hsl(var(--primary))]"
                            />
                        </div>
                    </div>

                    {/* Options */}
                    <div className="max-h-[200px] overflow-y-auto p-1">
                        {loading ? (
                            <div className="py-4 text-center text-sm text-[hsl(var(--muted-foreground))]">
                                Đang tải...
                            </div>
                        ) : filteredOptions.length === 0 ? (
                            <div className="py-4 text-center text-sm text-[hsl(var(--muted-foreground))]">
                                {search ? 'Không tìm thấy' : 'Đã chọn tất cả'}
                            </div>
                        ) : (
                            filteredOptions.map((opt) => (
                                <button
                                    key={opt.value}
                                    type="button"
                                    onClick={() => handleSelect(opt.value)}
                                    className={cn(
                                        'w-full flex items-center gap-3 px-3 py-2.5 rounded-lg text-left text-sm transition-colors',
                                        'hover:bg-[hsl(var(--muted))]'
                                    )}
                                >
                                    {opt.avatar ? (
                                        <img
                                            src={opt.avatar}
                                            alt={opt.label}
                                            className="h-8 w-8 rounded-full object-cover"
                                        />
                                    ) : (
                                        <div className="h-8 w-8 rounded-full bg-gradient-to-br from-emerald-500 to-cyan-500 flex items-center justify-center text-white text-xs font-bold">
                                            {opt.label[0]?.toUpperCase()}
                                        </div>
                                    )}
                                    <span className="flex-1">{opt.label}</span>
                                    {value.includes(opt.value) && (
                                        <Check className="h-4 w-4 text-[hsl(var(--primary))]" />
                                    )}
                                </button>
                            ))
                        )}
                    </div>
                </div>
            )}
        </div>
    )
}
