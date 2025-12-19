import './index.css'
import AppRouter from '@/routes'
import { Toaster } from 'sonner'

function App() {
  return (
    <>
      <AppRouter />
      <Toaster
        position="top-right"
        toastOptions={{
          style: {
            background: 'hsl(220 20% 12%)',
            border: '1px solid hsl(220 20% 20%)',
            color: 'hsl(220 10% 95%)',
          },
        }}
      />
    </>
  )
}

export default App
