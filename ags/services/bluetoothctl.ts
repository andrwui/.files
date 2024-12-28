
class BluetoothService extends Service {
  static {

    Service.register(

      this,
      {
        'device-changed': ['boolean'],
      },
      {
        'is-connected': ['boolean', 'r'],
      },
    )
  }

  #btInfo = Utils.exec('bluetoothctl info')




  #isConnected = this.#btInfo === '' ? false : true

  get is_connected() {
    return this.#isConnected
  }

  constructor() {
    super()

    Utils.interval(1000, () => {

      const btInfo = Utils.exec('bluetoothctl info')
      console.log({ btInfo })



      this.#isConnected = btInfo === '' ? false : true

      this.changed('is-connected')

      //@ts-ignore
      this.emit('device-changed', this.#isConnected)
    })

  }

}

const bluetooth = new BluetoothService

export default bluetooth
