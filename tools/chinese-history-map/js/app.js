/**
 * 中国古代汉人王朝疆域互动地图
 * 核心逻辑：初始化 Leaflet、加载王朝数据、管理图层与信息面板
 */

// 全局状态
let currentDynasty = null;
let currentLayers = [];
let map = null;

/**
 * 计算 GeoJSON 的边界框
 * @param {Object} geojson - GeoJSON 对象
 * @returns {L.LatLngBounds|null} Leaflet 边界框，若数据无效则返回 null
 */
function getBoundsFromGeoJSON(geojson) {
    if (!geojson || !geojson.features || geojson.features.length === 0) {
        return null;
    }
    try {
        const layer = L.geoJSON(geojson);
        const bounds = layer.getBounds();
        layer.remove(); // 临时图层立即清理，避免内存泄漏
        return bounds && bounds.isValid() ? bounds : null;
    } catch (e) {
        console.warn('计算 GeoJSON 边界框失败:', e);
        return null;
    }
}

/**
 * 清除当前地图上的所有动态图层
 */
function clearLayers() {
    currentLayers.forEach(layer => {
        if (map && map.hasLayer(layer)) {
            map.removeLayer(layer);
        }
    });
    currentLayers = [];
}

/**
 * 更新右侧信息面板
 * @param {Object} data - 王朝数据对象
 */
function updateInfoPanel(data) {
    // 王朝标题与时期
    const nameEl = document.getElementById('dynasty-name');
    const periodEl = document.getElementById('dynasty-period');
    const capitalEl = document.getElementById('dynasty-capital');

    if (nameEl) nameEl.textContent = data.name || '未命名王朝';
    if (periodEl) periodEl.textContent = data.period || '—';
    if (capitalEl) capitalEl.textContent = '都城：' + (data.capital || '—');

    // 疆域变化原因
    const changesEl = document.getElementById('changes-content');
    if (changesEl) {
        changesEl.textContent = data.territoryChanges || '暂无疆域变化说明。';
    }

    // 皇帝列表
    const emperorsEl = document.getElementById('emperors-list');
    if (emperorsEl) {
        emperorsEl.innerHTML = '';
        if (Array.isArray(data.emperors) && data.emperors.length > 0) {
            data.emperors.forEach(emperor => {
                const card = document.createElement('div');
                card.className = 'emperor-card';

                const nameDiv = document.createElement('div');
                nameDiv.className = 'name';
                nameDiv.textContent = emperor.name || '无名';

                const metaDiv = document.createElement('div');
                metaDiv.className = 'meta';
                const metaParts = [];
                if (emperor.reign) metaParts.push('在位：' + emperor.reign);
                if (emperor.templeName) metaParts.push('庙号：' + emperor.templeName);
                if (emperor.posthumousTitle) metaParts.push('谥号：' + emperor.posthumousTitle);
                metaDiv.textContent = metaParts.join(' · ');

                card.appendChild(nameDiv);
                card.appendChild(metaDiv);

                if (emperor.evaluation) {
                    const evalDiv = document.createElement('div');
                    evalDiv.className = 'evaluation';
                    evalDiv.textContent = emperor.evaluation;
                    card.appendChild(evalDiv);
                }

                emperorsEl.appendChild(card);
            });
        } else {
            emperorsEl.innerHTML = '<div class="text-block">暂无皇帝记录。</div>';
        }
    }

    // 行政州/郡表格
    const provincesTbody = document.getElementById('provinces-tbody');
    if (provincesTbody) {
        provincesTbody.innerHTML = '';
        if (Array.isArray(data.provinces) && data.provinces.length > 0) {
            data.provinces.forEach(province => {
                const tr = document.createElement('tr');
                const tdName = document.createElement('td');
                tdName.textContent = province.name || '—';
                const tdType = document.createElement('td');
                tdType.textContent = province.type || '—';
                const tdCapital = document.createElement('td');
                tdCapital.textContent = province.capital || '—';
                tr.appendChild(tdName);
                tr.appendChild(tdType);
                tr.appendChild(tdCapital);
                provincesTbody.appendChild(tr);
            });
        } else {
            const tr = document.createElement('tr');
            const td = document.createElement('td');
            td.colSpan = 3;
            td.textContent = '暂无行政州/郡记录。';
            td.style.textAlign = 'center';
            tr.appendChild(td);
            provincesTbody.appendChild(tr);
        }
    }
}

/**
 * 加载指定王朝数据并渲染到地图
 * @param {string} dynastyId - 王朝 ID，如 "qin"
 */
function loadDynasty(dynastyId) {
    if (!map) {
        console.warn('地图尚未初始化，无法加载王朝');
        return;
    }

    const data = (typeof DYNASTY_DATA !== 'undefined') ? DYNASTY_DATA[dynastyId] : null;
    if (!data) {
        console.warn('未找到王朝数据:', dynastyId);
        return;
    }

    // 更新当前王朝状态
    currentDynasty = dynastyId;

    // 清除旧图层
    clearLayers();

    // 更新左侧按钮激活状态
    document.querySelectorAll('.dynasty-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.id === dynastyId);
    });

    // 加载概览疆域 GeoJSON
    if (data.overviewGeoJSON) {
        const overviewLayer = L.geoJSON(data.overviewGeoJSON, {
            style: function() {
                return {
                    fillColor: data.overviewColor || 'rgba(200,50,50,0.3)',
                    color: data.overviewBorder || '#c83232',
                    weight: 2,
                    opacity: 1,
                    fillOpacity: 0.45
                };
            },
            onEachFeature: function(feature, layer) {
                const popupContent = '<strong>' + (data.name || '未知王朝') + '</strong>' +
                    (data.period ? '<br>' + data.period : '');
                layer.bindPopup(popupContent);
                layer.on('mouseover', function() {
                    layer.setStyle({ weight: 3, fillOpacity: 0.6 });
                });
                layer.on('mouseout', function() {
                    layer.setStyle({ weight: 2, fillOpacity: 0.45 });
                });
            }
        });
        overviewLayer.addTo(map);
        currentLayers.push(overviewLayer);
    }

    // 加载敌人/周边政权 GeoJSON
    if (Array.isArray(data.enemies)) {
        data.enemies.forEach(enemy => {
            if (!enemy.geoJSON) return;
            const enemyLayer = L.geoJSON(enemy.geoJSON, {
                style: function() {
                    return {
                        fillColor: enemy.color || 'rgba(100,100,100,0.25)',
                        color: enemy.borderColor || '#666666',
                        weight: 1.5,
                        opacity: 0.9,
                        fillOpacity: 0.3
                    };
                },
                onEachFeature: function(feature, layer) {
                    if (enemy.name) {
                        layer.bindPopup(enemy.name);
                    }
                }
            });
            enemyLayer.addTo(map);
            currentLayers.push(enemyLayer);
        });
    }

    // 添加行政州/郡治所标记
    if (Array.isArray(data.provinces)) {
        data.provinces.forEach(province => {
            if (!province.center || province.center.length < 2) return;
            // 约定 data.js 中 center 为 [经度, 纬度]，Leaflet 需要 [纬度, 经度]
            const latLng = [province.center[1], province.center[0]];
            const marker = L.circleMarker(latLng, {
                radius: 6,
                fillColor: '#38bdf8',
                color: '#0f172a',
                weight: 1.5,
                opacity: 1,
                fillOpacity: 0.85
            });

            marker.bindTooltip(
                (province.name || '未知') + (province.capital ? '（治：' + province.capital + '）' : ''),
                { direction: 'top', offset: [0, -4] }
            );

            marker.on('mouseover', function() {
                marker.setStyle({ radius: 9, fillOpacity: 1, color: '#ffffff' });
            });
            marker.on('mouseout', function() {
                marker.setStyle({ radius: 6, fillOpacity: 0.85, color: '#0f172a' });
            });

            marker.addTo(map);
            currentLayers.push(marker);
        });
    }

    // 调整地图视野
    let targetBounds = null;
    if (data.overviewGeoJSON) {
        targetBounds = getBoundsFromGeoJSON(data.overviewGeoJSON);
    }
    // 若无疆域数据，尝试从敌人数据计算边界
    if (!targetBounds && Array.isArray(data.enemies)) {
        for (const enemy of data.enemies) {
            if (enemy.geoJSON) {
                const b = getBoundsFromGeoJSON(enemy.geoJSON);
                if (b) {
                    targetBounds = targetBounds ? targetBounds.extend(b) : b;
                }
            }
        }
    }
    // 若仍无边界，使用所有 province 中心点
    if (!targetBounds && Array.isArray(data.provinces)) {
        const validPoints = data.provinces
            .filter(p => p.center && p.center.length === 2)
            .map(p => [p.center[1], p.center[0]]);
        if (validPoints.length > 0) {
            targetBounds = L.latLngBounds(validPoints);
        }
    }

    if (targetBounds && targetBounds.isValid()) {
        map.flyToBounds(targetBounds, { padding: [40, 40], maxZoom: 7, duration: 1.2 });
    } else {
        // 默认回退到东亚中心
        map.flyTo([35, 105], 4, { duration: 1 });
    }

    // 更新信息面板
    updateInfoPanel(data);
}

/**
 * 初始化应用
 */
function initApp() {
    // 初始化 Leaflet 地图
    map = L.map('map', {
        center: [35, 105],
        zoom: 4,
        minZoom: 3,
        maxZoom: 10,
        zoomControl: true,
        attributionControl: true
    });

    // 添加 OpenStreetMap 底图
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        subdomains: ['a', 'b', 'c'],
        maxZoom: 19
    }).addTo(map);

    // 添加地图图例控件（Leaflet Control）
    const legendControl = L.control({ position: 'bottomright' });
    legendControl.onAdd = function() {
        const div = L.DomUtil.create('div', 'map-legend leaflet-bar');
        div.style.background = 'rgba(15, 23, 42, 0.85)';
        div.style.padding = '8px 10px';
        div.style.border = '1px solid rgba(148, 163, 184, 0.2)';
        div.style.borderRadius = '6px';
        div.style.color = '#f1f5f9';
        div.style.fontSize = '12px';
        div.style.lineHeight = '1.6';
        div.innerHTML =
            '<div style="margin-bottom:4px;font-weight:600;">图例</div>' +
            '<div><span style="display:inline-block;width:12px;height:12px;background:rgba(200,50,50,0.5);border:1px solid #c83232;border-radius:2px;margin-right:6px;vertical-align:middle;"></span>汉人王朝疆域</div>' +
            '<div><span style="display:inline-block;width:12px;height:12px;background:rgba(100,100,100,0.35);border:1px solid #666;border-radius:2px;margin-right:6px;vertical-align:middle;"></span>外敌/周边政权</div>' +
            '<div><span style="display:inline-block;width:12px;height:12px;background:#38bdf8;border-radius:50%;margin-right:6px;vertical-align:middle;"></span>行政州/郡治所</div>';
        return div;
    };
    legendControl.addTo(map);

    // 生成左侧王朝选择按钮
    const dynastyListEl = document.getElementById('dynasty-list');
    if (dynastyListEl && typeof DYNASTY_DATA !== 'undefined') {
        const dynastyIds = Object.keys(DYNASTY_DATA);
        if (dynastyIds.length === 0) {
            dynastyListEl.innerHTML = '<div class="text-block" style="padding:0.5rem;">暂无王朝数据</div>';
        } else {
            dynastyIds.forEach(id => {
                const d = DYNASTY_DATA[id];
                const btn = document.createElement('button');
                btn.className = 'dynasty-btn';
                btn.dataset.id = id;
                btn.textContent = (d.name || id);
                btn.addEventListener('click', function() {
                    loadDynasty(id);
                });
                dynastyListEl.appendChild(btn);
            });
        }

        // 默认加载第一个王朝（优先 qin）
        if (dynastyIds.length > 0) {
            const defaultId = dynastyIds.includes('qin') ? 'qin' : dynastyIds[0];
            loadDynasty(defaultId);
        }
    } else {
        if (dynastyListEl) {
            dynastyListEl.innerHTML = '<div class="text-block" style="padding:0.5rem;">数据加载失败</div>';
        }
        console.warn('DYNASTY_DATA 未定义或王朝列表面板不存在');
    }
}

// 页面加载完成后启动
if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initApp);
} else {
    initApp();
}
