Для запуска локальной сети hardhat 

Инициализацися проекта
```
npx hardhat --init
```
Перед повторным запуском сети, её нужно всегда чистить
```
npx hardhat clean
```
Запуск сети
```
npx hardhat node
```

В другом терминале:

Установить зависимости openzeppelin
```
npm install @openzeppelin/contracts
```
Компиляция
```
npx hardhat compile
```
Деплой - специальный скрипт 
```
npx hardhat run --network localhost scripts/deploy.js
```

При ошибках:

Please install Hardhat locally using pnpm, npm or yarn, and try again.
For more info go to https://hardhat.org/HHE22 or run Hardhat with --show-stack-traces
```
npm install --save-dev hardhat
```
