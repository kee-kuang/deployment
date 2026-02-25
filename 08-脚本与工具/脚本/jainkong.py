<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Domain Availability Checker</title>
</head>
<body>

    <!-- 用于显示域名状态的 div -->
    <div id="domain-status" style="display: none;">Loading...</div>

    <!-- 这里可以放置你的网站内容 -->

    <script src="https://cdn.jsdelivr.net/npm/jquery@3.6.0/dist/jquery.min.js"></script>
    <script type="text/javascript">
        $(document).ready(function() {
            // 定时器间隔时间（单位：毫秒）
            const delay = 5000; // 每5秒检查一次
            let checkInterval;

            function checkDomainAvailability(domain) {
                fetch(`https://www.verisign-grs.com/rpa/domaincheck/${domain}`)
                    .then(response => response.json())
                    .catch(error => console.error('Error checking domain:', error))
                    .then(data => {
                        if (data.status === 'Available') {
                            $('#domain-status').text(`The domain "${domain}" is available.`);
                        } else if (data.status === 'Reserved' || data.status === 'Unavailable') {
                            $('#domain-status').text(`The domain "${domain}" is not available or reserved.`);
                        } else {
                            $('#domain-status').text('Checking...');
                        }
                    });
            }

            // 选择一个要检查的域名
            const myDomain = 'yuetougz.com';

            checkInterval = setInterval(() => {
                checkDomainAvailability(myDomain);
            }, delay);

            // 初始化时检查域名是否可用
            checkDomainAvailability(myDomain);
        });

        $(document).on('click', '#check-now', function() {
            clearInterval(checkInterval);
            checkInterval = null;
            checkDomainAvailability(myDomain, true); // 如果是点击按钮启动检查，可以传入第二个参数表示强制检查
        });
    </script>
</body>
</html>