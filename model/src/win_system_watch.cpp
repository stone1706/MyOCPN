/***************************************************************************
 *   Copyright (C) 2024  Alec Leamas                                       *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,  USA.         *
 **************************************************************************/

/** \file win_system_watch.cpp Implement win_system_watch.h */

#include <thread>

#include "model/win_system_watch.h"

using namespace std::literals::chrono_literals;


WinSystemWatchDaemon::~WinSystemWatchDaemon() { Stop(); }

// windows pseudocode:
static void HandleUsbEvent(void* the_daemon) {
    auto watch_daemon = static_cast<WinSystemWatchDaemon*>(the_daemon);
    watch_daemon->m_sys_events.evt_resume.Notify();
}

void WinSystemWatchDaemon::DoStart() {
  // Windows pseudocode:
  // install_event_handler(handle_usb_event, this);
  //     // Assuming we can feed a pointer to the event handler.

  while (!done) {
    std::this_thread::sleep_for(100ms);     // debug variant
  }

  // std::unique_lock lock(m_mutex);    // production code
  // m_cv.wait(lock, [done] { return done; });
}

void WinSystemWatchDaemon::Start() {
  if (m_thread.joinable()) return;  // already running
  m_thread = std::thread([&]{ DoStart(); });
}

void WinSystemWatchDaemon::Stop() {
  done = true;     // Debug variant

  // {             // Production code
  //   std::lock_guard lock(m_mutex);
  //   done = true;
  // }
  if (!m_thread.joinable()) return;  // Already stopped
  m_thread.join();
}
