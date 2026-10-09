# DiPlay · 吉利 ICON / E01 车机适配

面向**吉利 ICON 2020 款 · E01 车机**的 CarPlay 接收端适配。以社区实测数据为驱动，先在真实固件上跑通基线，再逐步推进无线、方向盘按键与 HUD。

> **当前状态：固件普查阶段。尚未发布任何可用 APK。**
> 在拿到足够多的 E01 固件分支样本之前不做代码分叉——避免在没有基线的情况下重复造轮子。

---

## 为什么单独开这个仓库

| 现有项目 | 覆盖范围 | 与 E01 的关系 |
|---|---|---|
| `shihabal3amri/DiPlay`（上游） | 仅比亚迪 DiLink，Android 9+ / API 28 | E01 是 Android 5.1（API 22），官方包装不上 |
| `programmerguohuajing/DiPlay-Legacy-Android` | Android 4.4+ / API 19，手动热点无线 | **v0.2.7 理论上可安装**，但无任何非比亚迪车机的公开验证记录 |
| `xikai6282/DiPlay-Geely-Android43` | 博瑞 H52 / i.MX6 / **Android 4.3** | 目标版本与 E01 的 5.1 不一致，其固件桥接不适用于 E01 |

三者都不覆盖 **ICON / E01 / Android 5.1**。

**重要提醒：吉利 ICON 2020 款存在两个批次**——2020 年 6 月前生产的多为 Android 4.3，之后为 5.1。本仓库主线服务 **5.1（API 22）**；4.3 车主请先看 `xikai6282/DiPlay-Geely-Android43`，并在固件普查表中注明你的分支。

---

## 路线图

### 阶段 0 · 固件普查（当前）

- 收集 ICON 2020 车主的`系统版本`完整串、`硬件版本`、`MCU 版本`、分辨率、root 状态
- 目标：**至少 30 份样本**，识别出 E01 存在几个固件分支
- 产出：`docs/FIRMWARE-CENSUS.md` 中的固件分支表

> 这一步跳过，后面所有适配都是在赌。

### 阶段 1 · 基线验证

- 在普查出的每个主流分支上验证 `DiPlay-Legacy-Android v0.2.7`：能否安装、能否启动、有线 USB 能否出画面
- 产出：`docs/COMPATIBILITY.md` 兼容矩阵

### 阶段 2 · 有线跑通

- 定位失败阶段（握手 / 授权 / 出画面 / 出声 / 触控）
- 优先解决通用层问题（老 API 兼容、USB 协议、后台保活），此类改动可回流上游

### 阶段 3 · 无线与原车集成

- 手动内置热点的无线链路
- 方向盘按键、原厂蓝牙通路、首次启动优化

---

## 关于 APK 分发

**本仓库不分发、不托管任何可用的已签名 APK，也不包含任何认证身份资产。**

原因与做法：

1. 上游与 Legacy 分支的源码构建**故意不含配件身份**（`docs/BUILD.md`），源码编译出的包无法完成 CarPlay 认证。
2. 可用包必须包含 `offline-mfi/identity.pk8` 与 `offline-mfi/certificate.p7b`，这两个文件**不进 Git**（上游与本项目均设有构建守卫）。
3. 因此本项目提供**本地重打包脚本**（`scripts/repack.sh`）：你用自己的官方渠道 APK 作为输入，在本地完成 patch + 重签名，产物仅供本人使用。

这样做的边界是：仓库里没有身份资产、没有私钥、没有现成可装包；使用者自己承担组装与使用的全部责任。

```bash
# 用法（示意，脚本尚未最终确定）
./scripts/repack.sh -i DiPlay-Legacy-Android-v0.2.7.apk -o DiPlay-E01-local.apk
```

> 重签名后的包名与签名均不同于官方包，**不能覆盖升级**，需先卸载旧包（卸载前请导出诊断报告）。

---

## 参与方式

- **车友（不会写代码）**：填 `docs/FIRMWARE-CENSUS.md` 的样本表 → 跑 `docs/TESTING.md` 清单 → 按 issue 模板提交
- **开发者**：先读 `CONTRIBUTING.md`，从 `good first issue` 入手
- 提交任何内容前请完成**脱敏检查**：删除蓝牙 MAC、VIN、热点名称与密码、手机号、Apple ID

---

## 许可与署名

本项目基于以下项目，均为 **GPL-3.0**，本项目同样以 GPL-3.0 发布：

- `shihabal3amri/DiPlay`（上游）
- `programmerguohuajing/DiPlay-Legacy-Android`（低版本 Android 适配）
- `xikai6282/DiPlay-Geely-Android43`（吉利 4.3 适配，参考其打包与桥接思路）

---

## 免责声明

- 本仓库**不是 Apple 认证产品**。CarPlay 认证依赖从公开固件提取的实验性配件身份，未来 iOS 更新可能导致失效，无任何保证。
- 车机安装第三方 APK 可能影响原厂功能、OTA 与质保。请在驻车状态下操作，操作前自行备份。
- 与 Apple Inc.、吉利汽车、比亚迪均无关联。CarPlay 名称与图标归 Apple Inc. 所有。
