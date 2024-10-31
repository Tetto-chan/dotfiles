const currencyList = [
	'USD',
	'EUR',
	'RUB',
	'BYN',
	'PLN',
	'UAH',
	'GEL',
	'KZT',
	'TRY',
	'CNY',
	'BTC',
	'ETH',
	'TON',
	'ZEC',
	'XMR',
	'LTC',
	'ZCL',
]

const flags = {
	'USD' : '🇺🇸',
	'PLN' : '🇵🇱',
	'EUR' : '🇪🇺',
	'BYN' : '🇧🇾',
	'RUB' : '🇷🇺',
	'UAH' : '🇺🇦',
	'GEL' : '🇬🇪',
	'KZT' : '🇰🇿',
	'TRY' : '🇹🇷',
	'CNY' : '🇨🇳',
}

const signs = {
	'USD' : '$',
	'EUR' : '€',
	'RUB' : '₽',
	'BYN' : 'р.',
	'PLN' : 'zł',
	'UAH' : '₴',
	'GEL' : '₾',
	'KZT' : '₸',
	'TRY' : '₺',
	'CNY' : '¥',
}

let data = {}
let engine = (navigator.userAgent.search(/(Firefox)/) > 0) ? browser : chrome;

class SimpleCalc {
	static evaluateExpression(expression) {
		expression = expression.replace(/\s+/g, '');

		const tokens = SimpleCalc.tokenize(expression);
		if (!tokens) {
			throw new Error('Invalid expression');
		}

		const postfix = SimpleCalc.infixToPostfix(tokens);

		return SimpleCalc.evaluatePostfix(postfix);
	}

	static tokenize(expression) {
		const tokens = [];
		let numberBuffer = [];

		for (let char of expression) {
			if (/\d|\./.test(char)) {
				numberBuffer.push(char);
			} else if ('+-*/()'.includes(char)) {
				if (numberBuffer.length) {
					tokens.push(numberBuffer.join(''));
					numberBuffer = [];
				}
				tokens.push(char);
			} else {
				return null;
			}
		}

		if (numberBuffer.length) {
			tokens.push(numberBuffer.join(''));
		}

		return tokens;
	}

	static infixToPostfix(tokens) {
		const outputQueue = [];
		const operatorStack = [];
		const operators = {
			'+': { precedence: 1, associativity: 'Left' },
			'-': { precedence: 1, associativity: 'Left' },
			'*': { precedence: 2, associativity: 'Left' },
			'/': { precedence: 2, associativity: 'Left' }
		};

		tokens.forEach(token => {
			if (!isNaN(parseFloat(token))) {
				outputQueue.push(token);
			} else if ('+-*/'.includes(token)) {
				while (operatorStack.length && '*/+-'.includes(operatorStack[operatorStack.length - 1])) {
					let top = operatorStack[operatorStack.length - 1];
					if ((operators[token].associativity === 'Left' && operators[token].precedence <= operators[top].precedence) ||
						(operators[token].associativity === 'Right' && operators[token].precedence < operators[top].precedence)) {
						outputQueue.push(operatorStack.pop());
					} else {
						break;
					}
				}
				operatorStack.push(token);
			} else if (token === '(') {
				operatorStack.push(token);
			} else if (token === ')') {
				while (operatorStack.length && operatorStack[operatorStack.length - 1] !== '(') {
					outputQueue.push(operatorStack.pop());
				}
				operatorStack.pop();
			}
		});

		while (operatorStack.length) {
			outputQueue.push(operatorStack.pop());
		}

		return outputQueue;
	}

	static evaluatePostfix(postfix) {
		const resultStack = [];
		postfix.forEach(token => {
			if (!isNaN(parseFloat(token))) {
				resultStack.push(parseFloat(token));
			} else {
				let b = resultStack.pop();
				let a = resultStack.pop();
				switch (token) {
					case '+':
						resultStack.push(a + b);
						break;
					case '-':
						resultStack.push(a - b);
						break;
					case '*':
						resultStack.push(a * b);
						break;
					case '/':
						resultStack.push(a / b);
						break;
					default:
						throw new Error('Invalid operator');
				}
			}
		});

		if (resultStack.length !== 1) {
			throw new Error('Invalid expression');
		}

		return resultStack[0];
	}
}

function locale() {
	document.querySelectorAll('[data-lang]').forEach(function(element) {
		let langKey = element.getAttribute('data-lang')
		let newText = engine.i18n.getMessage(langKey)
		if (newText) {
			element.innerText = newText
		}
	})
}

function init() {
	engine.storage.local.get()
		.then(value => {
			data = value;
			if (!data['options']) {
				data['options'] = {}
			}
		})
		.then(initForm)
}

function initForm() {
	document.querySelector('.col').style.width = 'calc(130px * ' + (data.options.columns ?? 1) +')'

	// отобразим список
	for(let currency of currencyList) {
		const isVisible = (data['options']['show-' + currency] === undefined) ? true : !!data['options']['show-' + currency];

		if (!isVisible) {
			continue;
		}

		let extClass = ''
		let label = ''

		switch (data.options.labelType) {
			case 'FLAG':
				label = flags[currency] ? flags[currency] : currency
				extClass = flags[currency] ? 'flag' : ''
				break;
			case 'SIGN':
				label = signs[currency] ? signs[currency] : currency
				extClass = signs[currency] ? 'sign' : ''
				break;
			default:
				label = currency
		}

		$('.currency .col').append(
			'<div class="item">' +
			'    <input type="text" data-id="USD/'+currency+'" class="conv-edit" value=""/>' +
			'    <span class="label-currency ' + extClass + '">' + label + '</span>'+
			'</div>'
		)
	}

	// пропишем стартовое значение для всех
	let startFrom = (data.options.startFrom === undefined) ? 'USD' : data.options.startFrom
	let base = 'USD/' + startFrom
	let value = 1

	if (startFrom === 'LAST') {
		base = data.options.lastRateId ?? 'USD/USD'
		value = data.options.lastValue ?? 1
	}

	recalculate(base, value);

	// события редактирования курса
	let allElems = document.querySelectorAll('.conv-edit');
	for (let key in allElems) {
		if (!allElems.hasOwnProperty(key)) {
			continue;
		}

		// let curRateID = allElems[key].getAttribute('data-id');

		// весим обработчик событий
		allElems[key].addEventListener('input', function() {
			let options = data.options;
			let equation = this.value.replace(' ', '')

			try {
				options['lastValue'] = SimpleCalc.evaluateExpression(equation)
			} catch (error) {
				options['lastValue'] = ''
			}

			options['lastRateId'] = this.getAttribute('data-id')
			recalculate(options['lastRateId'], options['lastValue'])
			engine.storage.local.set({'options' : options})
		}, false);
	}

	if (data.updated) {
		let updatedAt = new Date(data.updated * 1000)
		let	timeOffsetInHours = (new Date().getTimezoneOffset()/60) * (-1);
		updatedAt.setHours(updatedAt.getHours() + timeOffsetInHours);
		document.getElementById('updated').textContent =
			updatedAt.toISOString().split("T")[0]
			+ ' ' +
			updatedAt.toISOString().split("T")[1].slice(0, 5)
	} else {
		document.getElementsByClassName('updated')[0].style.display = 'none'
	}
}

function conv(kurs, val, reverse) {
	kurs = kurs || '0'
	kurs = '' + kurs

	if (val === undefined) {
		val = 1
	}

	if (reverse === undefined) {
		reverse = false
	}

	val = '' + val
	let result
	let preparedValue = parseFloat(val.replace(',', '.'))
	let preparedRate = parseFloat(kurs.replace(',', '.'))

	if (reverse) {
		result = preparedValue / preparedRate
	} else {
		result = preparedValue * preparedRate
	}

	if (isNaN(result)) {
		return 0
	}

	if (result < 1000) {
		result = result.toFixed(2)
		let spl = (result + '').split('.')

		return spl[0].replace(/(\d{1,3})(?=((\d{3})*([^\d]|$)))/g, " $1").concat('.' + spl[1]).trim()
	} else {
		result = result.toFixed(0)

		return result.replace(/(\d{1,3})(?=((\d{3})*([^\d]|$)))/g, " $1").trim()
	}
}

function recalculate(curRateID, curVal) {
	curVal = '' + curVal;
	let allElems = document.querySelectorAll('.conv-edit');
	let inUSD;

	// Переведем в USD
	if (curRateID !== 'USD/USD') {
		let rate = '' + data[curRateID] ?? '';
		document.querySelector('.conv-edit[data-id="USD/USD"]').value = conv(rate, curVal, true);
		inUSD = parseFloat(curVal.replace(',', '.')) / parseFloat(rate.replace(',', '.'));
	} else {
		inUSD = curVal;
	}

	let curElement = document.querySelector('.conv-edit[data-id="'+curRateID+'"]')
	if (curElement.value === '') {
		curElement.value = curVal;
	}

	// Пересчитаем для всех кроме текущей
	for (let key2 in allElems) {
		if (!allElems.hasOwnProperty(key2)) {
			continue;
		}

		let curRateID2 = allElems[key2].getAttribute('data-id');
		if (curRateID2 === curRateID || curRateID2 === 'USD/USD') {
			continue;
		}

		allElems[key2].value = conv(data[curRateID2], inUSD, false);
	}
}

window.onload = () => {
	$(document).on('click', '#setting', function() {
		if ($('.tab.options:visible').length ){
			return
		}

		$('.tab.options').show();
		$('.tab.currency').hide();

		// отобразим список
		for(let currency of currencyList) {
			let isVisible = (data['options']['show-' + currency] === undefined) ? true : !!data['options']['show-' + currency];
			let checkedText = isVisible ? 'checked' : '';
			let disabled = false

			if (currency === 'USD') {
				disabled = true
			}

			let disabledText = disabled ? 'disabled' : '';

			$('.options .cols').append('<label><input type="checkbox" data-id="USD/'+currency+'" '+checkedText+' '+disabledText+'/><span>'+currency+'</span></label>');
		}

		let labelType = (data.options.labelType === undefined) ? 'TEXT' : data.options.labelType;
		$('[name="labelType"]').val(labelType);

		let startFrom = (data.options.startFrom === undefined) ? 'USD' : data.options.startFrom;
		$('[name="startFrom"]').val(startFrom);

		let columns = (data.options.columns === undefined) ? 1 : data.options.columns;
		$('[name="columns"]').val(columns);
	})

	// клик по чекбоксу
	$(document).on('change', '[type="checkbox"], [name="startFrom"], [name="labelType"], [name="columns"]', function() {
		let options = {};
		for(let currency of currencyList) {
			options['show-' + currency] = $('.cols input[type="checkbox"][data-id="USD/'+currency+'"]').prop('checked')
		}

		options.startFrom = $('[name="startFrom"]').val()
		options.labelType = $('[name="labelType"]').val()
		options.columns = $('[name="columns"]').val()
		options.onFlags = $('[name="onFlags"]').is(':checked')

		engine.storage.local.set({'options' : options})
	})

	init()
	locale()
}
