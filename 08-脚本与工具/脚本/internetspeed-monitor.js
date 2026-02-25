// 每 5 秒记录当前上下行速率（单位 KB/s）
let now = new Date().toISOString();
let up = ($network.uploadSpeed / 1024).toFixed(2);
let down = ($network.downloadSpeed / 1024).toFixed(2);
$persistentStore.write(`${now},${up},${down}\n`, "speed_log");
$done();
