import { createBrowserRouter, RouterProvider } from 'react-router-dom'
import RootLayout from '@/components/RootLayout'
import DashboardPage from '@/pages/DashboardPage'
import SongsPage from '@/pages/SongsPage'
import ArtistsPage from '@/pages/ArtistsPage'
import AlbumsPage from '@/pages/AlbumsPage'
import GenresPage from '@/pages/GenresPage'
import PlaylistsPage from '@/pages/PlaylistsPage'
import UsersPage from '@/pages/UsersPage'
import PodcastsPage from '@/pages/PodcastsPage'

const router = createBrowserRouter([
    {
        path: '/',
        element: <RootLayout />,
        children: [
            { index: true, element: <DashboardPage /> },
            { path: 'songs', element: <SongsPage /> },
            { path: 'artists', element: <ArtistsPage /> },
            { path: 'albums', element: <AlbumsPage /> },
            { path: 'genres', element: <GenresPage /> },
            { path: 'playlists', element: <PlaylistsPage /> },
            { path: 'podcasts', element: <PodcastsPage /> },
            { path: 'users', element: <UsersPage /> },
        ],
    },
])

export default function AppRouter() {
    return <RouterProvider router={router} />
}
