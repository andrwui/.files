import { bind, exec, execAsync, timeout, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalMpris from 'gi://AstalMpris'
import Separator from '../../_generic/Separator'
import { truncate } from '../../../../../helper/helper'

const ChromePlayer = () => {
  const formatSongLength = (length: number) => {
    const min = Math.floor(length / 60)
    const sec = Math.floor(length % 60)
    const sec0 = sec < 10 ? '0' : ''
    return `${min}:${sec0}${sec}`
  }

  const chromeDbusInstance = exec([
    'bash',
    '-e',
    '/home/andrw/.files/ags/widget/bar/windows/sound/music/getChromeDbus.sh',
  ])
    .trim()
    .split('.')
    .slice(3, 5)
    .join('.')

  const chromeAvailable = !!chromeDbusInstance

  let chrome = null

  if (chromeAvailable) {
    chrome = AstalMpris.Player.new(chromeDbusInstance)
  }

  console.log(chromeDbusInstance)

  const chromeBinding = Variable<
    [
      boolean,
      string,
      string,
      string,
      string,
      AstalMpris.PlaybackStatus,
      number,
      number,
      AstalMpris.Loop,
      AstalMpris.Shuffle,
    ]
  >([
    false,
    '',
    '',
    '',
    '',
    AstalMpris.PlaybackStatus.STOPPED,
    0,
    0,
    AstalMpris.Loop.NONE,
    AstalMpris.Shuffle.OFF,
  ])

  const isDebouncing = Variable<boolean>(false)

  if (chrome) {
    Variable.derive(
      [
        bind(chrome, 'available'),
        bind(chrome, 'title'),
        bind(chrome, 'artist'),
        bind(chrome, 'album'),
        bind(chrome, 'coverArt'),
        bind(chrome, 'playbackStatus'),
        bind(chrome, 'position'),
        bind(chrome, 'length'),
        bind(chrome, 'loopStatus'),
        bind(chrome, 'shuffleStatus'),
      ],
      (
        isAvailable,
        songTitle,
        songArtist,
        songAlbum,
        songCover,
        playbackStatus,
        position,
        length,
        loopStatus,
        shuffleStatus,
      ) => {
        chromeBinding.set([
          isAvailable,
          songTitle,
          songArtist,
          songAlbum,
          songCover,
          playbackStatus,
          position,
          length,
          loopStatus,
          shuffleStatus,
        ])
      },
    )
  }

  return chrome ? (
    <>
      {bind(chromeBinding).as(
        ([
          isAvailable,
          songTitle,
          songArtist,
          songAlbum,
          songCover,
          playbackStatus,
          songPosition,
          songLength,
          loopStatus,
          shuffleStatus,
        ]) => {
          return isAvailable ? (
            <box
              spacing={10}
              vertical
              widthRequest={340}
            >
              <Separator />
              <label
                label={'Chrome'}
                halign={Gtk.Align.START}
                css="font-size: 18;"
              />
              <box
                vertical
                spacing={15}
              >
                <box spacing={10}>
                  <eventbox
                    halign={Gtk.Align.START}
                    heightRequest={70}
                    widthRequest={125}
                    cursor={'pointer'}
                    css={`
                      background-image: url('${songCover}');
                      background-size: cover;
                      background-repeat: no-repeat;
                      border-radius: 5px;
                    `}
                    onClick={() => exec(['bash', '-e', 'chrome'])}
                  />
                  <box
                    vertical
                    valign={Gtk.Align.CENTER}
                  >
                    <label
                      tooltipText={songTitle}
                      label={truncate(songTitle, 18)}
                      halign={Gtk.Align.START}
                      css={`
                        font-size: 20px;
                        font-weight: 500;
                      `}
                    />
                    <label
                      label={songArtist}
                      halign={Gtk.Align.START}
                      css={`
                        font-size: 12px;
                        font-weight: 500;
                      `}
                    />
                    <label
                      label={truncate(songAlbum, 30)}
                      halign={Gtk.Align.START}
                      css={`
                        font-size: 15px;
                        font-weight: 300;
                      `}
                    />
                  </box>
                </box>
                <box
                  vertical
                  spacing={10}
                >
                  <centerbox>
                    <label
                      halign={Gtk.Align.START}
                      label={formatSongLength(songPosition)}
                    />
                    <box></box>
                    <label
                      halign={Gtk.Align.END}
                      label={formatSongLength(songLength)}
                    />
                  </centerbox>
                  <slider
                    hexpand
                    heightRequest={10}
                    cursor={'pointer'}
                    css={`
                      border-radius: 2px;
                    `}
                    onDragged={({ value }) => {
                      if (isDebouncing.get()) return
                      timeout(500, () => {
                        chrome.position = value * songLength
                      })
                    }}
                    value={songPosition / songLength}
                  />
                </box>
                <box halign={Gtk.Align.FILL}>
                  <centerbox spacing={10}>
                    <box hexpand>
                      <eventbox
                        halign={Gtk.Align.START}
                        onClick={() => chrome.shuffle()}
                        cursor={'pointer'}
                      ></eventbox>
                      <eventbox
                        hexpand
                        halign={Gtk.Align.END}
                      ></eventbox>
                    </box>
                    <eventbox
                      halign={Gtk.Align.CENTER}
                      onClick={() => chrome.play_pause()}
                      cursor={'pointer'}
                    >
                      <icon
                        css={`
                          font-size: 18px;
                        `}
                        icon={
                          playbackStatus === AstalMpris.PlaybackStatus.PLAYING ? 'pause' : 'play'
                        }
                      />
                    </eventbox>
                    <box hexpand>
                      <eventbox
                        hexpand
                        halign={Gtk.Align.START}
                      ></eventbox>
                      <eventbox halign={Gtk.Align.END}></eventbox>
                    </box>
                  </centerbox>
                </box>
              </box>
            </box>
          ) : (
            ''
          )
        },
      )}
    </>
  ) : (
    ''
  )
}

export default ChromePlayer
