import { bind, Variable } from 'astal'
import { Gtk } from 'astal/gtk3'
import AstalNetwork from 'gi://AstalNetwork'
import { areApsSame, filterAps } from './helper'
import { truncate } from '../../../../helper/helper'
import GenericTextButton from '../_generic/GenericTextButton'

import { selectedAp } from './variables'

import NetworkPasswordRevealer from './password/NetworkPasswordRevealer'

const NetworkList = () => {
  const wifi = AstalNetwork.get_default().wifi

  const { START, FILL, END } = Gtk.Align

  const wifiBinding = Variable<
    [AstalNetwork.AccessPoint[], AstalNetwork.AccessPoint] | [null, null]
  >([null, null])

  Variable.derive(
    [bind(wifi, 'accessPoints'), bind(wifi, 'activeAccessPoint')],
    (aps, activeAp) => {
      wifiBinding.set([aps, activeAp])
    },
  )

  return (
    <box
      vertical
      spacing={10}
    >
      <box>
        <label label="Access points" />
        <GenericTextButton
          hexpand
          halign={END}
          onClick={() => wifi.scan()}
          cursor="pointer"
        >
          <icon
            icon="search-c"
            css={bind(wifi, 'scanning').as(
              (isScanning) => `
                ${isScanning ? 'animation: blink .5s infinite alternate' : ''};
                font-size: 18px;
                `,
            )}
          />
        </GenericTextButton>
      </box>

      <scrollable
        heightRequest={300}
        widthRequest={350}
      >
        <box
          orientation={1}
          spacing={5}
        >
          {bind(wifiBinding).as(([accessPoints, activeAccessPoint]) => {
            if (accessPoints) {
              return filterAps(accessPoints).map((ap) => (
                <eventbox
                  cursor="pointer"
                  onClick={() => {
                    if (!selectedAp.get() || selectedAp.get()?.ssid != ap.ssid) {
                      selectedAp.set(ap)
                    } else {
                      selectedAp.set(null)
                    }
                  }}
                  hexpand
                  halign={FILL}
                  tooltipText={ap.ssid}
                >
                  <box>
                    <label
                      hexpand
                      halign={START}
                      label={`${truncate(ap.ssid, 15)} ${areApsSame(ap, activeAccessPoint || new AstalNetwork.AccessPoint()) ? '' : ''}`}
                    />

                    <icon
                      className="smallText"
                      halign={END}
                      widthRequest={20}
                      css={`
                        font-size: 20px;
                      `}
                      icon={`${ap.strength < 40 ? 'wifi-zero' : ap.strength < 60 ? 'wifi-low' : ap.strength < 80 ? 'wifi-high' : 'wifi'}`}
                    />
                  </box>
                </eventbox>
              ))
            }
          })}
        </box>
      </scrollable>
      <NetworkPasswordRevealer />
    </box>
  )
}

export default NetworkList
