import { timeout, Variable } from 'astal'
import AstalAuth from 'gi://AstalAuth?version=0.1'
import LockScreenState from '@/singleton/lockScreenState/LockScreenState'
import { Durations } from '@/constants/constants'
import Gdk from 'gi://Gdk?version=3.0'
import { defaultLockMsg } from './Lock'

type LockEntryProps = {
  message: Variable<string>
}
export default function LockEntry({ message }: LockEntryProps) {
  const PAM = AstalAuth.Pam

  const lockScreenState = LockScreenState.getInstance()

  const pass = Variable<string>('')
  const canWrite = Variable<boolean>(true)

  return (
    <entry
      primary_icon_name={'i-lock'}
      className="entry"
      placeholderText={'Password'}
      sensitive={canWrite()}
      visibility={false}
      hasFocus
      canFocus
      text={pass()}
      onDraw={(self) => {
        self.grab_focus_without_selecting()
      }}
      onChanged={(self) => pass.set(self.text)}
      onKeyPressEvent={(self, ev) => {
        self.grab_focus_without_selecting()
        if (ev.get_keyval()[1] === Gdk.KEY_Escape) {
          lockScreenState.set(false)
        }
        if (ev.get_keyval()[1] === 65293) {
          canWrite.set(false)
          message.set('Authenticating...')
          PAM.authenticate(pass.get(), (_, task) => {
            pass.set('')
            try {
              PAM.authenticate_finish(task)
              message.set('')
              timeout(Durations.TRANSITION + 100, () => {
                message.set(defaultLockMsg)
              })
              lockScreenState.set(false)
              canWrite.set(true)
            } catch (err) {
              message.set('Incorrect password.')
              canWrite.set(true)
            }
          })
        }
      }}
    />
  )
}
