import * as React from 'react'
import { ChevronDown, Check } from 'lucide-react'
import { cn } from '@/lib/utils'

interface SelectContextValue {
    value: string
    onValueChange: (value: string) => void
    open: boolean
    setOpen: (open: boolean) => void
}

const SelectContext = React.createContext<SelectContextValue | null>(null)

interface SelectProps {
    value: string
    onValueChange: (value: string) => void
    children: React.ReactNode
}

export function Select({ value, onValueChange, children }: SelectProps) {
    const [open, setOpen] = React.useState(false)

    return (
        <SelectContext.Provider value={{ value, onValueChange, open, setOpen }}>
            <div className="relative">
                {children}
            </div>
        </SelectContext.Provider>
    )
}

interface SelectTriggerProps extends React.ButtonHTMLAttributes<HTMLButtonElement> {
    children: React.ReactNode
}

export const SelectTrigger = React.forwardRef<HTMLButtonElement, SelectTriggerProps>(
    ({ className, children, ...props }, ref) => {
        const context = React.useContext(SelectContext)
        if (!context) throw new Error('SelectTrigger must be used within Select')

        return (
            <button
                ref={ref}
                type="button"
                role="combobox"
                aria-expanded={context.open}
                onClick={() => context.setOpen(!context.open)}
                className={cn(
                    'flex h-10 w-full items-center justify-between rounded-md border border-[hsl(var(--input))] bg-[hsl(var(--background))] px-3 py-2 text-sm ring-offset-[hsl(var(--background))] placeholder:text-[hsl(var(--muted-foreground))] focus:outline-none focus:ring-2 focus:ring-[hsl(var(--ring))] focus:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50',
                    className
                )}
                {...props}
            >
                {children}
                <ChevronDown className="h-4 w-4 opacity-50" />
            </button>
        )
    }
)
SelectTrigger.displayName = 'SelectTrigger'

interface SelectValueProps {
    placeholder?: string
}

export function SelectValue({ placeholder }: SelectValueProps) {
    const context = React.useContext(SelectContext)
    if (!context) throw new Error('SelectValue must be used within Select')

    return (
        <span className={cn(!context.value && 'text-[hsl(var(--muted-foreground))]')}>
            {context.value || placeholder}
        </span>
    )
}

interface SelectContentProps {
    children: React.ReactNode
}

export function SelectContent({ children }: SelectContentProps) {
    const context = React.useContext(SelectContext)
    if (!context) throw new Error('SelectContent must be used within Select')

    if (!context.open) return null

    return (
        <>
            <div
                className="fixed inset-0 z-40"
                onClick={() => context.setOpen(false)}
            />
            <div className="absolute top-full left-0 right-0 z-50 mt-1 max-h-60 overflow-auto rounded-md border border-[hsl(var(--border))] bg-[hsl(var(--popover))] text-[hsl(var(--popover-foreground))] shadow-md animate-in fade-in-0 zoom-in-95">
                <div className="p-1">
                    {children}
                </div>
            </div>
        </>
    )
}

interface SelectItemProps {
    value: string
    children: React.ReactNode
    disabled?: boolean
}

export function SelectItem({ value, children, disabled }: SelectItemProps) {
    const context = React.useContext(SelectContext)
    if (!context) throw new Error('SelectItem must be used within Select')

    const isSelected = context.value === value

    return (
        <div
            role="option"
            aria-selected={isSelected}
            data-disabled={disabled}
            onClick={() => {
                if (!disabled) {
                    context.onValueChange(value)
                    context.setOpen(false)
                }
            }}
            className={cn(
                'relative flex w-full cursor-pointer select-none items-center rounded-sm py-1.5 pl-8 pr-2 text-sm outline-none',
                'hover:bg-[hsl(var(--accent))] hover:text-[hsl(var(--accent-foreground))]',
                'focus:bg-[hsl(var(--accent))] focus:text-[hsl(var(--accent-foreground))]',
                disabled && 'pointer-events-none opacity-50'
            )}
        >
            {isSelected && (
                <span className="absolute left-2 flex h-3.5 w-3.5 items-center justify-center">
                    <Check className="h-4 w-4" />
                </span>
            )}
            {children}
        </div>
    )
}
