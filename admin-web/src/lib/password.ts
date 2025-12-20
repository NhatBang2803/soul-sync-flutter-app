// Password hashing utility using Web Crypto API
// This creates a SHA-256 hash with salt for password storage

export async function hashPassword(password: string): Promise<string> {
    // Generate a random salt
    const salt = crypto.getRandomValues(new Uint8Array(16))
    const saltHex = Array.from(salt).map(b => b.toString(16).padStart(2, '0')).join('')

    // Encode password with salt
    const encoder = new TextEncoder()
    const data = encoder.encode(saltHex + password)

    // Hash using SHA-256
    const hashBuffer = await crypto.subtle.digest('SHA-256', data)
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')

    // Return salt:hash format
    return `${saltHex}:${hashHex}`
}

export async function verifyPassword(password: string, storedHash: string): Promise<boolean> {
    const [salt, originalHash] = storedHash.split(':')
    if (!salt || !originalHash) return false

    const encoder = new TextEncoder()
    const data = encoder.encode(salt + password)

    const hashBuffer = await crypto.subtle.digest('SHA-256', data)
    const hashArray = Array.from(new Uint8Array(hashBuffer))
    const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('')

    return hashHex === originalHash
}
