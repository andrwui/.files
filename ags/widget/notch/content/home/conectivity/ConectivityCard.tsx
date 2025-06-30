import { Durations } from '@/constants/constants'
import { Binding } from 'astal'
import { Gtk } from 'astal/gtk3'

type ConectivityCardProps = {
  icons: Record<string, string>
  currentIcon?: string | Binding<string | undefined>
  onButtonClick?: () => void
  label?: string | Binding<string | undefined>
  arrowsIcon?: 'white' | 'black' | Binding<'black' | 'white' | undefined>
  containerClass: string | Binding<string | undefined>
  onTextClick: () => void
}

export default function ConectivityCard({
  icons,
  currentIcon,
  onButtonClick,
  label,
  arrowsIcon,
  containerClass,
  onTextClick,
}: ConectivityCardProps) {
  return (
    <box
      className={
        typeof containerClass === 'object' && 'as' in containerClass
          ? containerClass.as((className: string | undefined) => `panel-card ${className ?? ''}`)
          : `panel-card ${containerClass}`
      }
      halign={Gtk.Align.FILL}
      width_request={150}
      spacing={5}
    >
      <button
        className="switch-button"
        onClick={onButtonClick}
        halign={Gtk.Align.FILL}
        cursor="pointer"
      >
        <stack
          visibleChildName={currentIcon}
          transitionType={Gtk.StackTransitionType.CROSSFADE}
          transitionDuration={Durations.TRANSITION}
        >
          {Object.values(icons).map((icon) => {
            return (
              <icon
                name={icon}
                icon={icon}
                className="icon"
              />
            )
          })}
        </stack>
      </button>
      <eventbox
        cursor="pointer"
        onClick={onTextClick}
      >
        <box
          spacing={5}
          width_request={100}
        >
          <label
            halign={Gtk.Align.START}
            label={label}
            className={'name'}
            maxWidthChars={8}
            truncate
          />
          <stack
            visibleChildName={arrowsIcon}
            transitionType={Gtk.StackTransitionType.CROSSFADE}
            transitionDuration={Durations.TRANSITION}
          >
            <icon
              name="white"
              icon="i-chevrons-up-down"
            />
            <icon
              name="black"
              icon="i-chevrons-up-down-black"
            />
          </stack>
        </box>
      </eventbox>
    </box>
  )
}
