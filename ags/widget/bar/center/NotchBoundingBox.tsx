import NotchState, { NotchStateType } from '@/singleton/notchState/NotchState'

export default function NotchBoundingBox({ isPrimary }: { isPrimary: boolean }) {
  const notchState = NotchState.getInstance()

  return (
    <eventbox
      vexpand
      onHover={() => {
        if (isPrimary) {
          notchState.set(NotchStateType.HOVERED)
        }
      }}
      onHoverLost={() => {
        notchState.set(NotchStateType.NORMAL)
      }}
    />
  )
}

