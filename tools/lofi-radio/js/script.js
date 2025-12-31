document.addEventListener('DOMContentLoaded', function() {
    // 初始化
    initRandomElements();
    updateConsoleLines();
    initAudioControls();
    initBackgroundEffects();
    initThemeSelector();

    // 为控制台添加更多内容
    setInterval(addRandomConsoleLines, 7000);
});

// 视频链接配置
const videoLinks = {
    'space': 'https://player.bilibili.com/player.html?isOutside=true&aid=531725955&bvid=BV18u411H7Kj&cid=1218282405&p=1',
    'night-bus': 'https://player.bilibili.com/player.html?isOutside=true&aid=113219398009968&bvid=BV19JxrehEUH&cid=26056852779&p=1',
    'bar': 'https://player.bilibili.com/player.html?isOutside=true&aid=704837335&bvid=BV1hQ4y1s7XK&cid=1302130728&p=1'
};

// 主题对应的标题和副标题
const themeTexts = {
    'space': {
        title: '太空赫兹电台',
        subtitle: '某个赶工的夜晚 你打开太空赫兹 边听电台边工作'
    },
    'night-bus': {
        title: '夜行巴士电台',
        subtitle: '你错过了深夜最后一班公交车 决定一个人步行回家'
    },
    'bar': {
        title: '午夜酒吧电台',
        subtitle: '打烊后的酒吧空无一人 你看着窗外的城市灯光 给自己调制了一杯马提尼'
    }
};

// 控制台消息管理
const consoleMessages = {
    'space': [
        '接收来自太空深处的信号...',
        '频率调节到87.5 MHz',
        'Lofi节拍：64 BPM',
        '氛围特性: 环境白噪音增强中',
        '电台信号来源: 猎户座星云',
        '信号强度: 优',
        '检测到深空电波干扰，正在过滤...',
        '播放环境过滤算法v2.4',
        '压缩失真已修正',
        '空间立体声效果已加载',
        '添加轻微氛围混响...',
        '检测到听众喜欢的节奏模式',
        '遥测数据：放松指数 92%',
        '电台状态：正常运行中',
        '宇宙背景辐射已同步',
        '流媒体缓冲：100%'
    ],
    'night-bus': [
        '夜行模式已激活',
        '正在播放深夜电台频道',
        '当前时间：凌晨2:37',
        '环境雨声增强中...',
        '录制环境：雨夜街道',
        '步行节奏匹配：80 BPM',
        '路灯照明强度：低',
        '检测到雨滴噪声',
        '混合城市环境声',
        '通勤人流密度：极低',
        '播放列表：夜间漫步系列',
        '情绪调节算法：活跃中',
        '夜行氛围：宁静但略带忧伤',
        '路线预测：住宅区',
        '距离目的地：1.7公里'
    ],
    'bar': [
        '午夜酒吧模式已启动',
        '播放列表：爵士与电子混合',
        '环境噪音：低语与冰块碰撞声',
        '调酒配方已显示...',
        '城市灯光强度：中等',
        '雨后玻璃窗效果增强',
        'Lofi节拍：58 BPM',
        '爵士钢琴元素检测',
        '空间混响：中等酒吧空间',
        '酒精浓度监测：适中',
        '灯光色温：暖黄色调',
        '窗外交通密度：稀疏',
        '杯中液体：马提尼，加橄榄',
        '播放情绪：沉思但放松',
        '当前氛围评级：完美适合独处'
    ]
};

// 初始化主题选择器功能
function initThemeSelector() {
    const themeSelect = document.getElementById('theme-select');
    
    // 设置初始主题
    changeTheme('space');
    
    // 监听主题切换事件
    themeSelect.addEventListener('change', function() {
        const selectedTheme = themeSelect.value;
        changeTheme(selectedTheme);
    });
}

// 切换主题函数
function changeTheme(theme) {
    // 更新body的class
    document.body.className = '';
    document.body.classList.add(theme + '-theme');
    
    // 更新标题和副标题
    const mainTitle = document.querySelector('.main-title');
    const subtitle = document.querySelector('.subtitle');
    
    mainTitle.textContent = themeTexts[theme].title;
    subtitle.textContent = themeTexts[theme].subtitle;
    
    // 更新视频链接
    const iframe = document.querySelector('.player-frame iframe');
    iframe.src = videoLinks[theme];
    
    // 添加控制台消息
    if (theme === 'space') {
        addConsoleMessage('已切换到太空赫兹主题');
    } else if (theme === 'night-bus') {
        addConsoleMessage('已切换到夜行巴士主题');
    } else if (theme === 'bar') {
        addConsoleMessage('已切换到午夜酒吧主题');
    }
}

// 初始化音频控制
function initAudioControls() {
    const playPauseButton = document.querySelector('.play-pause');
    const volumeUpButton = document.querySelector('.volume-up');
    const volumeDownButton = document.querySelector('.volume-down');
    
    // bilibili iframe 元素
    const biliPlayer = document.querySelector('.player-frame iframe');
    
    // 通过postMessage与bilibili播放器通信
    function postBiliMessage(action, data = {}) {
        const message = { action, data };
        biliPlayer.contentWindow.postMessage(JSON.stringify(message), '*');
    }
    
    // 播放/暂停控制
    playPauseButton.addEventListener('click', function() {
        if (playPauseButton.classList.contains('active')) {
            // 当前是播放状态，切换为暂停
            playPauseButton.innerHTML = '<i class="fas fa-play"></i>';
            playPauseButton.classList.remove('active');
            
            // 向bilibili播放器发送暂停消息
            postBiliMessage('pause');
            
            // 更新控制台消息
            addConsoleMessage('已暂停音频流');
        } else {
            // 当前是暂停状态，切换为播放
            playPauseButton.innerHTML = '<i class="fas fa-pause"></i>';
            playPauseButton.classList.add('active');
            
            // 向bilibili播放器发送播放消息
            postBiliMessage('play');
            
            // 更新控制台消息
            addConsoleMessage('音频流传输中...');
        }
    });
    
    // 音量增加控制
    volumeUpButton.addEventListener('click', function() {
        // 向bilibili播放器发送增加音量的消息
        postBiliMessage('volume', { value: '+0.1' });
        addConsoleMessage('音量提高');
    });
    
    // 音量减少控制
    volumeDownButton.addEventListener('click', function() {
        // 向bilibili播放器发送减少音量的消息
        postBiliMessage('volume', { value: '-0.1' });
        addConsoleMessage('音量降低');
    });
}

// 初始化背景效果
function initBackgroundEffects() {
    createStars();
    addShootingStars();
}

// 创建随机星星
function createStars() {
    const starsContainer = document.querySelector('.stars');
    const numberOfStars = 200;
    
    for (let i = 0; i < numberOfStars; i++) {
        const star = document.createElement('div');
        star.classList.add('star');
        
        // 随机位置
        star.style.left = `${Math.random() * 100}%`;
        star.style.top = `${Math.random() * 100}%`;
        
        // 随机大小
        const size = Math.random() * 2;
        star.style.width = `${size}px`;
        star.style.height = `${size}px`;
        
        // 随机闪烁动画
        star.style.animationDuration = `${3 + Math.random() * 7}s`;
        star.style.animationDelay = `${Math.random() * 5}s`;
        
        starsContainer.appendChild(star);
    }
}

// 添加多个流星
function addShootingStars() {
    const ambientObjects = document.querySelector('.ambient-objects');
    const numberOfStars = 5;
    
    for (let i = 0; i < numberOfStars; i++) {
        const shootingStar = document.createElement('div');
        shootingStar.classList.add('shooting-star');
        
        // 随机位置
        shootingStar.style.top = `${Math.random() * 70}%`;
        shootingStar.style.left = `${Math.random() * 20 - 100}px`;
        
        // 随机动画延迟
        shootingStar.style.animationDelay = `${Math.random() * 60}s`;
        
        ambientObjects.appendChild(shootingStar);
    }
}

// 初始化随机元素（卫星、行星等）
function initRandomElements() {
    // 随机切换行星位置和样式
    const planet = document.querySelector('.planet');
    if (planet) {
        setInterval(() => {
            // 随机位置
            planet.style.left = `${5 + Math.random() * 20}%`;
            planet.style.bottom = `${5 + Math.random() * 25}%`;
            
            // 随机颜色
            const r = Math.floor(60 + Math.random() * 70);
            const g = Math.floor(70 + Math.random() * 70);
            const b = Math.floor(200 + Math.random() * 55);
            planet.style.background = `radial-gradient(circle at 30% 30%, rgb(${r}, ${g}, ${b}), rgb(${r/3}, ${g/3}, ${b/2}))`;
        }, 20000);
    }
    
    // 周期性添加更多无线电波
    setInterval(() => {
        const waves = document.createElement('div');
        waves.classList.add('radio-waves');
        waves.style.top = `${20 + Math.random() * 60}%`;
        waves.style.left = `${20 + Math.random() * 60}%`;
        
        document.querySelector('.ambient-objects').appendChild(waves);
        
        // 动画结束后移除
        setTimeout(() => {
            if (waves && waves.parentNode) {
                waves.parentNode.removeChild(waves);
            }
        }, 5000);
    }, 8000);
}

// 更新控制台行
function updateConsoleLines() {
    const consoleScreen = document.querySelector('.console-screen');
    
    // 确保控制台屏幕存在
    if (!consoleScreen) return;
    
    // 初始化控制台行为控制台中现有的行
    let consoleLines = Array.from(consoleScreen.querySelectorAll('.console-line'));
    
    // 如果没有typing行，添加一个
    if (!consoleLines.some(line => line.classList.contains('typing'))) {
        // 获取当前主题
        const currentTheme = document.body.className.split('-')[0] || 'space';
        const themeMessages = consoleMessages[currentTheme] || consoleMessages['space'];
        
        const randomMessage = themeMessages[Math.floor(Math.random() * themeMessages.length)];
        addConsoleMessage(randomMessage, true);
    }
}

// 添加随机控制台行
function addRandomConsoleLines() {
    // 获取当前主题
    const currentTheme = document.body.className.split('-')[0] || 'space';
    const themeMessages = consoleMessages[currentTheme] || consoleMessages['space'];
    
    // 从消息列表中随机选择一条
    const randomIndex = Math.floor(Math.random() * themeMessages.length);
    const message = themeMessages[randomIndex];
    
    // 添加到控制台
    addConsoleMessage(message);
}

// 添加控制台消息
function addConsoleMessage(message, isTyping = false) {
    const consoleScreen = document.querySelector('.console-screen');
    
    // 确保控制台屏幕存在
    if (!consoleScreen) return;
    
    // 创建新行
    const newLine = document.createElement('div');
    newLine.classList.add('console-line');
    newLine.textContent = message;
    
    // 如果是打字行，添加typing类
    if (isTyping) {
        newLine.classList.add('typing');
    }
    
    // 移除任何现有的typing行
    const existingTypingLine = consoleScreen.querySelector('.typing');
    if (existingTypingLine) {
        existingTypingLine.classList.remove('typing');
    }
    
    // 追加新行
    consoleScreen.appendChild(newLine);
    
    // 保持滚动到底部
    consoleScreen.scrollTop = consoleScreen.scrollHeight;
    
    // 控制行数
    const lines = consoleScreen.querySelectorAll('.console-line');
    if (lines.length > 10) {
        consoleScreen.removeChild(lines[0]);
    }
}

// 监听窗口消息，获取bilibili播放器的状态更新
window.addEventListener('message', function(e) {
    try {
        const data = JSON.parse(e.data);
        if (data.type === 'player' && data.info) {
            // 处理来自播放器的各种消息
            if (data.info.status === 'playing') {
                document.querySelector('.play-pause').innerHTML = '<i class="fas fa-pause"></i>';
                document.querySelector('.play-pause').classList.add('active');
            } else if (data.info.status === 'pause') {
                document.querySelector('.play-pause').innerHTML = '<i class="fas fa-play"></i>';
                document.querySelector('.play-pause').classList.remove('active');
            }
        }
    } catch (err) {
        // 忽略无法解析的消息
    }
});
