/**
 * Godot 指南 - 交互脚本
 */

document.addEventListener('DOMContentLoaded', function () {
    // ===== 移动端导航切换 =====
    const navToggle = document.getElementById('navToggle');
    const navLinks = document.getElementById('navLinks');

    if (navToggle && navLinks) {
        navToggle.addEventListener('click', () => {
            navLinks.classList.toggle('open');
        });

        // 点击导航链接后关闭移动端菜单
        navLinks.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                navLinks.classList.remove('open');
            });
        });
    }

    // ===== 标签页切换 =====
    function initTabs(tabContainerId) {
        const container = document.getElementById(tabContainerId);
        if (!container) return;

        const buttons = container.querySelectorAll('.tab-btn');
        const parent = container.parentElement;

        buttons.forEach(btn => {
            btn.addEventListener('click', () => {
                const tabId = btn.dataset.tab;
                if (!tabId) return;

                // 切换按钮状态
                buttons.forEach(b => b.classList.remove('active'));
                btn.classList.add('active');

                // 切换内容
                const contents = parent.querySelectorAll('.tab-content');
                contents.forEach(c => c.classList.remove('active'));
                const target = parent.querySelector('#' + tabId);
                if (target) target.classList.add('active');
            });
        });
    }

    initTabs('langTabs');
    initTabs('aiTabs');

    // ===== 导航滚动高亮 =====
    const sections = document.querySelectorAll('section[id]');
    const navItems = document.querySelectorAll('.nav-links a[href^="#"]');

    function highlightNav() {
        let current = '';
        const scrollPos = window.scrollY + 100;

        sections.forEach(section => {
            const top = section.offsetTop;
            const height = section.offsetHeight;
            if (scrollPos >= top && scrollPos < top + height) {
                current = section.getAttribute('id');
            }
        });

        navItems.forEach(link => {
            link.classList.remove('active');
            const href = link.getAttribute('href').substring(1);
            if (href === current) {
                link.classList.add('active');
            }
        });
    }

    window.addEventListener('scroll', highlightNav);
    highlightNav();

    // ===== 导航栏背景过渡 =====
    const navbar = document.getElementById('navbar');
    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) {
                navbar.style.background = 'rgba(11, 15, 25, 0.95)';
            } else {
                navbar.style.background = 'rgba(11, 15, 25, 0.85)';
            }
        });
    }

    // ===== 平滑锚点滚动偏移（考虑固定导航栏） =====
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            const target = document.querySelector(targetId);
            if (target) {
                e.preventDefault();
                const offset = 70;
                const targetPos = target.getBoundingClientRect().top + window.scrollY - offset;
                window.scrollTo({ top: targetPos, behavior: 'smooth' });
            }
        });
    });
});
