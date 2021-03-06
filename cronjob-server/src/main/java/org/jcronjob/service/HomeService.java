/**
 * Copyright 2016 benjobs
 * <p>
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements. See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership. The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License. You may obtain a copy of the License at
 * <p>
 * http://www.apache.org/licenses/LICENSE-2.0
 * <p>
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

package org.jcronjob.service;

import org.jcronjob.dao.QueryDao;
import org.jcronjob.base.utils.Digests;
import org.jcronjob.base.utils.Encodes;
import org.jcronjob.domain.Log;
import org.jcronjob.domain.User;
import org.jcronjob.tag.Page;
import org.jcronjob.vo.LogVo;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.ui.Model;

import javax.servlet.http.HttpSession;

import java.util.List;

import static org.jcronjob.base.utils.CommonUtils.notEmpty;

/**
 * Created by ChenHui on 2016/2/17.
 */
@Service
public class HomeService {

    @Autowired
    private QueryDao queryDao;

    public int checkLogin(HttpSession httpSession, String username, String password) {
        //将session置为无效
        if (!httpSession.isNew()) {
            httpSession.invalidate();
            httpSession.removeAttribute("user");
        }

        User user = queryDao.hqlUniqueQuery("FROM User WHERE userName = ?", username);
        if (user == null) return 500;

        byte[] salt = Encodes.decodeHex(user.getSalt());
        byte[] hashPassword = Digests.sha1(password.getBytes(), salt, 1024);
        password = Encodes.encodeHex(hashPassword);

        String sql = "SELECT COUNT(1) FROM user WHERE userName=? AND password=?";
        Long count = queryDao.getCountBySql(sql, username, password);

        if (count == 1L) {
            httpSession.setAttribute("userId", user.getUserId());
            httpSession.setAttribute("user", username);
            if (user.getRoleId() == 999L) {
                httpSession.setAttribute("permission", true);
            } else {
                httpSession.setAttribute("permission", false);
            }
            return 200;
        } else {
            return 500;
        }
    }

    public Page<LogVo> getLog(HttpSession session, Page page, Long workerId, String sendTime) {
        String sql = "SELECT L.*,w.name AS workerName FROM log L LEFT JOIN worker w ON L.workerId = w.workerId WHERE 1=1 ";
        if (notEmpty(workerId)) {
            sql += " AND L.workerId = " + workerId;
        }
        if (notEmpty(sendTime)) {
            sql += " AND L.sendTime like '" + sendTime + "%' ";
        }
        if (!(Boolean) session.getAttribute("permission")) {
            sql += " AND L.receiverId = " + session.getAttribute("userId");
        }
        sql += " ORDER BY L.sendTime DESC";
        queryDao.getPageBySql(page, LogVo.class, sql);
        return page;
    }

    public List<LogVo> getMsg(HttpSession session) {
        String sql = "SELECT * FROM log L WHERE 1=1 ";
        if (!(Boolean) session.getAttribute("permission")) {
            sql += " and L.receiverId = " + session.getAttribute("userId");
        }
        sql += " ORDER BY L.sendTime DESC LIMIT 5";
        return queryDao.sqlQuery(LogVo.class,sql);
    }

    public void saveLog(Log log) {
        queryDao.save(log);
    }

    public Log getLogDetail(Long logId) {
        return queryDao.get(Log.class,logId);
    }
}
