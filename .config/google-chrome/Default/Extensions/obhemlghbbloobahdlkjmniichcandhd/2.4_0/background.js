let engine = (navigator.userAgent.search(/(Firefox)/) > 0) ? browser : chrome;

function getData() {
	fetch('https://api.iliz.net/json/currency.json', {
		headers: {
			'Accept': 'application/json'
		}}
	)
	.then(response => response.json())
	.then(function (response) {
		for(let key in response.fiat.rates) {
			let data = {}
			data['USD/' + key] = response.fiat.rates[key]
			engine.storage.local.set(data)
		}

		for(let key in response.crypto.rates) {
			let data = {}
			data['USD/' + key] = response.crypto.rates[key]
			engine.storage.local.set(data)
		}


		engine.storage.local.set({updated : response.fiat.timestamp})
	}).catch((e) => console.log('API error'))
}

engine.alarms.create('refresh_alarm', {periodInMinutes: 30})
engine.alarms.onAlarm.addListener((initiator) => {
	getData()
});

engine.runtime.onInstalled.addListener((reason) => {
	getData()

	engine.storage.local.get()
		.then(function(data) {
			if (!data.options) {
				data.options = {
					oneColumn : true,
					onFlags : true,
					labelType : 'FLAG',
				}

				engine.storage.local.set({'options' : data.options})
			}
		})
});
