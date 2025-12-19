import { useState, useEffect, useCallback } from 'react'
import { Users, Trash2, Search, Loader2, Mail, Calendar, User as UserIcon } from 'lucide-react'
import { toast } from 'sonner'

import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
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
import type { User } from '@/schemas'

export default function UsersPage() {
    const [users, setUsers] = useState<User[]>([])
    const [filteredUsers, setFilteredUsers] = useState<User[]>([])
    const [loading, setLoading] = useState(true)
    const [search, setSearch] = useState('')
    const [deleteDialogOpen, setDeleteDialogOpen] = useState(false)
    const [selectedUser, setSelectedUser] = useState<User | null>(null)

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

    const openDeleteDialog = (user: User) => {
        setSelectedUser(user)
        setDeleteDialogOpen(true)
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
                    </div>
                ) : (
                    <Table>
                        <TableHeader>
                            <TableRow>
                                <TableHead className="w-16"></TableHead>
                                <TableHead>Người dùng</TableHead>
                                <TableHead>Email</TableHead>
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
                                        <div className="flex items-center gap-2 text-[hsl(var(--muted-foreground))]">
                                            <Calendar className="h-3.5 w-3.5" />
                                            {user.created_at
                                                ? new Date(user.created_at).toLocaleDateString('vi-VN')
                                                : 'N/A'}
                                        </div>
                                    </TableCell>
                                    <TableCell className="text-right">
                                        <Button
                                            variant="ghost"
                                            size="icon"
                                            onClick={() => openDeleteDialog(user)}
                                            className="text-[hsl(var(--destructive))] hover:text-[hsl(var(--destructive))] hover:bg-[hsl(var(--destructive))]/10"
                                        >
                                            <Trash2 className="h-4 w-4" />
                                        </Button>
                                    </TableCell>
                                </TableRow>
                            ))}
                        </TableBody>
                    </Table>
                )}
            </div>

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
