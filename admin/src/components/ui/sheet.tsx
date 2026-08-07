import * as React from 'react'
import * as SheetPrimitive from '@radix-ui/react-dialog'
import { X } from 'lucide-react'
import { cn } from '@/lib/utils'

export const Sheet = SheetPrimitive.Root
export const SheetTrigger = SheetPrimitive.Trigger
export const SheetClose = SheetPrimitive.Close
export const SheetPortal = SheetPrimitive.Portal

export function SheetOverlay({ className, ...props }: React.ComponentProps<typeof SheetPrimitive.Overlay>) {
  return (
    <SheetPrimitive.Overlay
      className={cn('fixed inset-0 z-50 bg-black/40', className)}
      {...props}
    />
  )
}

export function SheetContent({
  className,
  children,
  side = 'right',
  ...props
}: React.ComponentProps<typeof SheetPrimitive.Content> & { side?: 'right' | 'left' }) {
  return (
    <SheetPortal>
      <SheetOverlay />
      <SheetPrimitive.Content
        className={cn(
          'fixed z-50 flex flex-col gap-4 overflow-y-auto overscroll-contain bg-surface shadow-xl transition ease-in-out',
          side === 'right' &&
            'inset-y-0 right-0 h-full w-full max-w-[100vw] border-l border-border p-4 pb-[max(1rem,env(safe-area-inset-bottom))] sm:max-w-xl sm:p-6',
          side === 'left' &&
            'inset-y-0 left-0 h-full w-full max-w-[100vw] border-r border-border p-4 pt-[max(1.5rem,env(safe-area-inset-top))] sm:max-w-xl sm:p-6',
          className
        )}
        {...props}
      >
        {children}
        <SheetPrimitive.Close className="absolute top-4 right-4 rounded-md p-1 text-ink-subtle hover:bg-cream-dark hover:text-ink">
          <X className="size-4" />
          <span className="sr-only">Close</span>
        </SheetPrimitive.Close>
      </SheetPrimitive.Content>
    </SheetPortal>
  )
}

export function SheetHeader({ className, ...props }: React.ComponentProps<'div'>) {
  return <div className={cn('flex flex-col gap-1 pr-8', className)} {...props} />
}

export function SheetTitle({ className, ...props }: React.ComponentProps<typeof SheetPrimitive.Title>) {
  return (
    <SheetPrimitive.Title className={cn('text-lg font-semibold text-ink', className)} {...props} />
  )
}

export function SheetDescription({ className, ...props }: React.ComponentProps<typeof SheetPrimitive.Description>) {
  return (
    <SheetPrimitive.Description className={cn('text-sm text-ink-muted', className)} {...props} />
  )
}

export function SheetFooter({ className, ...props }: React.ComponentProps<'div'>) {
  return (
    <div className={cn('mt-auto flex flex-col-reverse gap-2 border-t border-border pt-4 sm:flex-row sm:justify-end', className)} {...props} />
  )
}
