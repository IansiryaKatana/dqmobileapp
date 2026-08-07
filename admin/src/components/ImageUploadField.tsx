import { Upload, X, ImageIcon } from 'lucide-react'
import { useRef, useState } from 'react'
import { cn } from '@/lib/utils'
import { Button } from '@/components/ui/button'

type Props = {
  label?: string
  value: string | null | undefined
  onChange: (url: string | null) => void
  onUpload: (file: File) => Promise<void>
  uploading?: boolean
}

export function ImageUploadField({ label = 'Cover image', value, onChange, onUpload, uploading }: Props) {
  const inputRef = useRef<HTMLInputElement>(null)
  const [dragOver, setDragOver] = useState(false)

  async function handleFiles(files: FileList | null) {
    const file = files?.[0]
    if (!file?.type.startsWith('image/')) return
    await onUpload(file)
  }

  return (
    <div className="flex flex-col gap-2">
      <span className="text-sm font-medium text-ink">{label}</span>
      {value ? (
        <div className="relative overflow-hidden rounded-xl border border-border bg-cream-dark">
          <img src={value} alt="" className="h-40 w-full object-cover" />
          <Button
            type="button"
            variant="secondary"
            size="icon"
            className="absolute top-2 right-2 size-8 bg-surface/90"
            onClick={() => onChange(null)}
          >
            <X className="size-4" />
          </Button>
        </div>
      ) : (
        <button
          type="button"
          disabled={uploading}
          onClick={() => inputRef.current?.click()}
          onDragOver={(e) => {
            e.preventDefault()
            setDragOver(true)
          }}
          onDragLeave={() => setDragOver(false)}
          onDrop={(e) => {
            e.preventDefault()
            setDragOver(false)
            void handleFiles(e.dataTransfer.files)
          }}
          className={cn(
            'flex flex-col items-center justify-center gap-2 rounded-xl border-2 border-dashed px-6 py-10 transition-colors',
            dragOver ? 'border-accent bg-accent-soft' : 'border-border bg-surface hover:border-accent/50 hover:bg-cream-dark'
          )}
        >
          {uploading ? (
            <span className="text-sm text-ink-muted">Uploading…</span>
          ) : (
            <>
              <div className="flex size-12 items-center justify-center rounded-full bg-cream-dark text-accent">
                <Upload className="size-5" />
              </div>
              <div className="text-center">
                <p className="text-sm font-medium text-ink">Drop an image or click to browse</p>
                <p className="mt-1 text-xs text-ink-subtle">PNG, JPG, WebP up to 5MB</p>
              </div>
            </>
          )}
        </button>
      )}
      <input
        ref={inputRef}
        type="file"
        accept="image/*"
        className="hidden"
        onChange={(e) => void handleFiles(e.target.files)}
      />
      {value && (
        <div className="flex items-center gap-2 rounded-lg bg-cream-dark px-3 py-2 text-xs text-ink-muted">
          <ImageIcon className="size-3.5 shrink-0" />
          <span className="truncate">{value}</span>
        </div>
      )}
    </div>
  )
}
