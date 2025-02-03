import { bind, exec, timeout, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalMpris from 'gi://AstalMpris'
import Separator from '../../_generic/Separator'
import { truncate } from '../../../../../helper/helper'

const SpotifyPlayer = () => {
  const formatSongLength = (length: number) => {
    const min = Math.floor(length / 60)
    const sec = Math.floor(length % 60)
    const sec0 = sec < 10 ? '0' : ''
    return `${min}:${sec0}${sec}`
  }

  const spotify = AstalMpris.Player.new('spotify')

  const spotifyBinding = Variable<
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

  Variable.derive(
    [
      bind(spotify, 'available'),
      bind(spotify, 'title'),
      bind(spotify, 'artist'),
      bind(spotify, 'album'),
      bind(spotify, 'coverArt'),
      bind(spotify, 'playbackStatus'),
      bind(spotify, 'position'),
      bind(spotify, 'length'),
      bind(spotify, 'loopStatus'),
      bind(spotify, 'shuffleStatus'),
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
      spotifyBinding.set([
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

  return (
    <>
      {bind(spotifyBinding).as(
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
              <box
                vertical
                spacing={15}
              >
                <box spacing={10}>
                  <eventbox
                    halign={Gtk.Align.START}
                    heightRequest={100}
                    widthRequest={100}
                    cursor={'pointer'}
                    css={`
                      background-image: url('${songCover}');
                      background-size: contain;
                    `}
                    onClick={() => exec(['bash', '-e', 'spotify'])}
                  />
                  <box
                    vertical
                    valign={Gtk.Align.CENTER}
                  >
                    <label
                      label={truncate(songTitle, 15)}
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
                        font-size: 14px;
                        font-weight: 500;
                      `}
                    />
                    <label
                      label={truncate(songAlbum, 30)}
                      halign={Gtk.Align.START}
                      css={`
                        font-size: 11px;
                        font-weight: 200;
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
                    onDragged={({ value }) => {
                      if (isDebouncing.get()) return
                      timeout(500, () => {
                        spotify.position = value * songLength
                      })
                    }}
                    value={songPosition / songLength}
                  />
                </box>
                <box halign={Gtk.Align.FILL}>
                  <centerbox>
                    <box hexpand>
                      <eventbox
                        halign={Gtk.Align.START}
                        onClick={() => spotify.shuffle()}
                        cursor={'pointer'}
                      >
                        <label
                          label={'[shuffle]'}
                          css={`
                            color: ${shuffleStatus === AstalMpris.Shuffle.OFF ? '#171717' : ''};
                          `}
                        ></label>
                      </eventbox>
                      <eventbox
                        hexpand
                        halign={Gtk.Align.END}
                        onClick={() => spotify.previous()}
                        cursor={'pointer'}
                      >
                        {'[<]'}
                      </eventbox>
                    </box>
                    <eventbox
                      halign={Gtk.Align.CENTER}
                      onClick={() => spotify.play_pause()}
                      cursor={'pointer'}
                    >
                      {playbackStatus === AstalMpris.PlaybackStatus.PLAYING ? '[||]' : '[|>]'}
                    </eventbox>
                    <box hexpand>
                      <eventbox
                        cursor={'pointer'}
                        hexpand
                        halign={Gtk.Align.START}
                        onClick={() => spotify.next()}
                      >
                        {'[>]'}
                      </eventbox>
                      <eventbox
                        halign={Gtk.Align.END}
                        onClick={() => spotify.loop()}
                        cursor={'pointer'}
                      >
                        <label
                          label={`[loop${loopStatus === AstalMpris.Loop.TRACK ? '*' : ''}]`}
                          css={`
                            color: ${loopStatus === AstalMpris.Loop.NONE ? '#171717' : ''};
                          `}
                        ></label>
                      </eventbox>
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
  )
}

export default SpotifyPlayer
