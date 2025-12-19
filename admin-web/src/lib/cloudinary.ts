const CLOUD_NAME = import.meta.env.VITE_CLOUDINARY_CLOUD_NAME
const UPLOAD_PRESET = import.meta.env.VITE_CLOUDINARY_UPLOAD_PRESET

export interface UploadResult {
    secure_url: string
    public_id: string
    format: string
    duration?: number
    resource_type: string
}

export async function uploadToCloudinary(
    file: File,
    resourceType: 'image' | 'video' | 'raw' | 'auto' = 'auto',
    onProgress?: (percent: number) => void
): Promise<UploadResult> {
    const url = `https://api.cloudinary.com/v1_1/${CLOUD_NAME}/${resourceType}/upload`

    const formData = new FormData()
    formData.append('file', file)
    formData.append('upload_preset', UPLOAD_PRESET)

    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest()

        xhr.upload.addEventListener('progress', (e) => {
            if (e.lengthComputable && onProgress) {
                const percent = Math.round((e.loaded / e.total) * 100)
                onProgress(percent)
            }
        })

        xhr.addEventListener('load', () => {
            if (xhr.status >= 200 && xhr.status < 300) {
                const response = JSON.parse(xhr.responseText)
                resolve({
                    secure_url: response.secure_url,
                    public_id: response.public_id,
                    format: response.format,
                    duration: response.duration,
                    resource_type: response.resource_type,
                })
            } else {
                reject(new Error(`Upload failed: ${xhr.statusText}`))
            }
        })

        xhr.addEventListener('error', () => {
            reject(new Error('Upload failed'))
        })

        xhr.open('POST', url)
        xhr.send(formData)
    })
}

export function getFileType(file: File): 'image' | 'video' | 'raw' {
    if (file.type.startsWith('image/')) return 'image'
    if (file.type.startsWith('video/') || file.type.startsWith('audio/')) return 'video'
    return 'raw'
}
