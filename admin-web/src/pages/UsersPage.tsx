import { useState, useEffect, useCallback } from 'react'
import { useForm, Controller } from 'react-hook-form'
import { Users, Plus, Pencil, Trash2, Search, Loader2, Mail, Calendar, Key, Shield } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
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
import {
    Table,
    TableBody,
    TableCell,
    TableHead,
    TableHeader,
    TableRow,
} from '@/components/ui/table'

import { userService } from '@/services'
import { hashPassword } from '@/lib/password'
import type { User } from '@/schemas'

interface UserFormData {
    email: string
    username: string
    display_name: string
    password: string
    auth_method: 'local' | 'google'
}

export default function UsersPage() {
    const [users, setUsers] = useState<User[]>([])
    const [filteredUsers, setFilteredUsers] = useState<User[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [dialogOpen, setDialogOpen] = useState(false)
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedUser, setSelectedUser] = useState<User | null>(null)
    const [saving, setSaving] = useState(false)

    const form = useForm<UserFormData>({
        defaultValues: {
            email: '',
            username: '',
            display_name: '',
            password: '',
            auth_method: 'local',
        },
    })

    const authMethod = form.watch('auth_method')

    const loadUsers = useCallback(async () => {
        try {
            const data = await userService.getAll()
            setUsers(data)
            setFilteredUsers(data)
        } catch (error) {
            toast.error('Không thể tải danh sách người dùng')
            console.error(error)
        } finally {
            setLoading(false)
        }
    }, [])

    useEffect(() => {
        loadUsers()
    }, [loadUsers])

    useEffect(() => {
        const filtered = users.filter(
            (user) =>
                user.username?.toLowerCase().includes(search.toLowerCase()) ||
                user.email?.toLowerCase().includes(search.toLowerCase()) ||
                user.display_name?.toLowerCase().includes(search.toLowerCase())
        )
        setFilteredUsers(filtered)
    }, [search, users])

    const openCreateDialog = () => {
        setSelectedUser(null)
        form.reset({
            email: '',
            username: '',
            display_name: '',
            password: '',
            auth_method: 'local',
        })
        setDialogOpen(true)
    }

    const openEditDialog = (user: User) => {
        setSelectedUser(user)
        form.reset({
            email: user.email || '',
            username: user.username || '',
            display_name: user.display_name || '',
            password: '', // Don't show existing password
            auth_method: user.auth_method || 'local',
        })
        setDialogOpen(true)
    }

    const openDeleteDialog = (user: User) => {
        setSelectedUser(user)
        setDeleteDialogOpen(true)
    }

    const handleSubmit = async (data: UserFormData) => {
        setSaving(true)
        try {
            // Prepare user data
            const userData: Partial<User> = {
                email: data.email,
                username: data.username || null,
                display_name: data.display_name || null,
                auth_method: data.auth_method,
            }

            // Hash password if provided (required for local auth on create)
            if (data.password) {
                userData.password_hash = await hashPassword(data.password)
            } else if (!selectedUser && data.auth_method === 'local') {
                toast.error('Mật khẩu là bắt buộc cho phương thức đăng nhập Local')
                setSaving(false)
                return
            }

            if (selectedUser?.id) {
                await userService.update(selectedUser.id, userData)
                toast.success('Cập nhật người dùng thành công')
            } else {
                await userService.create(userData as Omit<User, 'id' | 'created_at'>)
                toast.success('Thêm người dùng thành công')
            }
            setDialogOpen(false)
            loadUsers()
        } catch (error) {
            toast.error('Có lỗi xảy ra')
            console.error(error)
        } finally {
            setSaving(false)
        }
    }

    const handleDelete = async () => {
        if (!selectedUser?.id) return
        try {
            await userService.delete(selectedUser.id)
            toast.success('Xóa người dùng thành công')
            setDeleteDialogOpen(false)
            loadUsers()
        } catch (error) {
            toast.error('Không thể xóa người dùng')
            console.error(error)
        }
    }

    const getAuthMethodBadge = (method: string) => {
        if (method === 'google') {
            return (
                <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-blue-500/20 text-blue-400">
                    <Shield className="h-3 w-3" />
                    Google
                </span>
            )
        }
        return (
            <span className="inline-flex items-center gap-1 px-2 py-0.5 rounded-full text-xs font-medium bg-emerald-500/20 text-emerald-400">
                <Key className="h-3 w-3" />
                Local
            </span>
        )
    }

    return (
        <div className="space-y-6 animate-fade-in">
            {/* Header */}
            <div className="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                <div className="flex items-center gap-3">
                    <div className="p-3 rounded-xl bg-gradient-to-br from-rose-500 to-pink-500 shadow-lg glow-subtle">
                        <Users className="h-6 w-6 text-white" />
                    </div>
                    <div>
                        <h1 className="text-2xl font-bold gradient-text">Người dùng</h1>
                        <p className="text-sm text-[hsl(var(--muted-foreground))]">
                            Quản lý tài khoản người dùng
                        </p>
                    </div>
                </div>
                <Button onClick={openCreateDialog} className="glow-subtle">
                    <Plus className="h-4 w-4 mr-2" />
                    Thêm người dùng
                </Button>
            </div>

            {/* Search */}
            <div className="ultra-glass-card p-4">
                <div className="relative">
                    <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-4 w-4 text-[hsl(var(--muted-foreground))]" />
                    <Input
                        placeholder="Tìm kiếm theo tên hoặc email..."
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
                ) : filteredUsers.length === 0 ? (
                    <div className="flex flex-col items-center justify-center py-16 gap-3">
                        <div className="h-16 w-16 rounded-2xl bg-gradient-to-br from-rose-500/20 to-pink-500/20 flex items-center justify-center">
                            <Users className="h-8 w-8 text-rose-400" />
                        </div>
                        <p className="text-[hsl(var(--muted-foreground))]">
                            {search ? 'Không tìm thấy người dùng' : 'Chưa có người dùng nào'}
                        </p>
                        {!search && (
                            <Button onClick={openCreateDialog} variant="outline" size="sm">
                                <Plus className="h-4 w-4 mr-1" />
                                Thêm người dùng đầu tiên
                            </Button>
                        )}
                    </div>
                ) : (
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead className="w-16"></TableHead>
                                <TableHead>Người dùng</TableHead>
                                <TableHead>Email</TableHead>
                                <TableHead>Phương thức</TableHead>
                                <TableHead>Ngày tham gia</TableHead>
                                <TableHead className="text-right">Thao tác</TableHead>
                            </TableRow>
                        </TableHeader>
                        <TableBody>
                            {filteredUsers.map((user, index) => (
                                <TableRow key={user.id} className="group" style={{ animationDelay: `${index * 50}ms` }}>
                                    <TableCell>
                                        <div className="h-10 w-10 rounded-full bg-[hsl(var(--muted))] overflow-hidden ring-2 ring-transparent group-hover:ring-[hsl(var(--primary))] transition-all">
                                            {user.avatar_url ? (
                                                <img
                                                    src={user.avatar_url}
                                                    alt={user.username || 'User'}
                                                    className="h-full w-full object-cover"
                                                />
                                            ) : (
                                                <div className="h-full w-full flex items-center justify-center bg-gradient-to-br from-rose-500 to-pink-500 text-white font-bold">
                                                    {(user.display_name || user.username || user.email || '?')[0].toUpperCase()}
                                                </div>
                                            )}
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        <div className="flex flex-col">
                                            <span className="font-medium">{user.display_name || user.username || 'Chưa đặt tên'}</span>
                                            {user.display_name && user.username && (
                                                <span className="text-xs text-[hsl(var(--muted-foreground))]">@{user.username}</span>
                                            )}
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        <div className="flex items-center gap-2 text-[hsl(var(--muted-foreground))]">
                                            <Mail className="h-3.5 w-3.5" />
                                            {user.email || 'Không có email'}
                                        </div>
                                    </TableCell>
                                    <TableCell>
                                        {getAuthMethodBadge(user.auth_method || 'local')}
                                    </TableCell>
                                    <TableCell>
                                        <div className="flex items-center gap-2 text-[hsl(var(--muted-foreground))]">
                                            <Calendar className="h-3.5 w-3.5" />
                                            {user.created_at
                                                ? new Date(user.created_at).toLocaleDateString('vi-VN')
                                                : 'N/A'}
                                        </div>
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <div className="flex items-center justify-end gap-1">
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                onClick={() => openEditDialog(user)}
                                                className="h-9 w-9 opacity-60 group-hover:opacity-100"
                                            >
                                                <Pencil className="h-4 w-4" />
                                            </Button>
                                            <Button
                                                variant="ghost"
                                                size="icon"
                                                onClick={() => openDeleteDialog(user)}
                                                className="text-[hsl(var(--destructive))] hover:text-[hsl(var(--destructive))] hover:bg-[hsl(var(--destructive))]/10"
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
                <DialogContent className="max-w-md">
                    <DialogHeader>
                        <DialogTitle className="gradient-text text-xl">
                            {selectedUser ? 'Chỉnh sửa người dùng' : 'Thêm người dùng mới'}
                        </DialogTitle>
                    </DialogHeader>
                    <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-4">
                        <div className="space-y-2">
                            <Label htmlFor="email">Email *</Label>
                            <Input
                                id="email"
                                type="email"
                                {...form.register('email', { required: 'Email là bắt buộc' })}
                                placeholder="user@example.com"
                                className="h-11"
                            />
                            {form.formState.errors.email && (
                                <p className="text-sm text-[hsl(var(--destructive))]">
                                    {form.formState.errors.email.message}
                                </p>
                            )}
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="username">Username</Label>
                            <Input
                                id="username"
                                {...form.register('username')}
                                placeholder="username"
                                className="h-11"
                            />
                            <p className="text-xs text-[hsl(var(--muted-foreground))]">
                                Dùng để đăng nhập thay email
                            </p>
                        </div>

                        <div className="space-y-2">
                            <Label htmlFor="display_name">Tên hiển thị</Label>
                            <Input
                                id="display_name"
                                {...form.register('display_name')}
                                placeholder="Nguyễn Văn A"
                                className="h-11"
                            />
                        </div>

                        <div className="space-y-2">
                            <Label>Phương thức đăng nhập *</Label>
                            <Controller
                                name="auth_method"
                                control={form.control}
                                render={({ field }) => (
                                    <Select value={field.value} onValueChange={field.onChange}>
                                        <SelectTrigger className="h-11">
                                            <SelectValue />
                                        </SelectTrigger>
                                        <SelectContent>
                                            <SelectItem value="local">
                                                <div className="flex items-center gap-2">
                                                    <Key className="h-4 w-4" />
                                                    Local (Email + Mật khẩu)
                                                </div>
                                            </SelectItem>
                                            <SelectItem value="google">
                                                <div className="flex items-center gap-2">
                                                    <Shield className="h-4 w-4" />
                                                    Google OAuth
                                                </div>
                                            </SelectItem>
                                        </SelectContent>
                                    </Select>
                                )}
                            />
                        </div>

                        {authMethod === 'local' && (
                            <div className="space-y-2">
                                <Label htmlFor="password">
                                    Mật khẩu {!selectedUser && '*'}
                                </Label>
                                <Input
                                    id="password"
                                    type="password"
                                    {...form.register('password')}
                                    placeholder={selectedUser ? 'Để trống nếu không đổi' : 'Nhập mật khẩu'}
                                    className="h-11"
                                />
                                {!selectedUser && (
                                    <p className="text-xs text-[hsl(var(--muted-foreground))]">
                                        Bắt buộc khi tạo tài khoản Local
                                    </p>
                                )}
                            </div>
                        )}

                        <DialogFooter className="gap-2 pt-4">
                            <Button type="button" variant="outline" onClick={() => setDialogOpen(false)}>
                                Hủy
                            </Button>
                            <Button type="submit" disabled={saving} className="min-w-[100px]">
                                {saving && <Loader2 className="h-4 w-4 mr-2 animate-spin" />}
                                {selectedUser ? 'Cập nhật' : 'Thêm'}
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
                            Bạn có chắc chắn muốn xóa người dùng "{selectedUser?.display_name || selectedUser?.username || selectedUser?.email}"?
                            Hành động này không thể hoàn tác và sẽ xóa toàn bộ dữ liệu liên quan.
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
