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

package org.jcronjob.controller;

import org.jcronjob.tag.Page;
import org.jcronjob.base.utils.JsonMapper;
import org.jcronjob.base.utils.PageIOUtils;
import org.jcronjob.domain.Role;
import org.jcronjob.domain.User;
import org.jcronjob.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.List;

import static org.jcronjob.base.utils.CommonUtils.notEmpty;

/**
 * Created by ChenHui on 2016/2/18.
 */
@Controller
@RequestMapping("/user")
public class UserController {

    @Autowired
    private UserService userService;

    @RequestMapping("/view")
    public String queryUser(Page page) {
        userService.queryUser(page);
        return "/user/view";
    }

    @RequestMapping("/self")
    public String querySelf(HttpSession session, Model model) {
        User user = userService.queryUserById((Long) session.getAttribute("userId"));
        model.addAttribute("u", user);
        return "/user/self";
    }

    @RequestMapping("addpage")
    public String addPage(Model model) {
        List<Role> role = userService.getRoleGroup();
        model.addAttribute("role", role);
        return "/user/add";
    }

    @RequestMapping("add")
    public String add(User user) {
        userService.addUser(user);
        return "redirect:/user/view";
    }

    @RequestMapping("/editpage")
    public String editPage(HttpSession session,Model model, Long id) {
        if (!(Boolean) session.getAttribute("permission")
                && Long.parseLong(session.getAttribute("userId").toString()) != id){
            return "redirect:/user/self";
        }
        User user = userService.queryUserById(id);
        List<Role> role = userService.getRoleGroup();
        model.addAttribute("role", role);
        model.addAttribute("u", user);
        return "/user/edit";
    }

    @RequestMapping("/edit")
    public String edit(HttpSession session, User user) {
        User user1 = userService.getUserById(user.getUserId());
        if (notEmpty(user.getRoleId()) && (Boolean) session.getAttribute("permission")) {
            user1.setRoleId(user.getRoleId());
        }
        user1.setRealName(user.getRealName());
        user1.setContact(user.getContact());
        user1.setEmail(user.getEmail());
        user1.setQq(user.getQq());
        user1.setModifyTime(new Date());
        userService.updateUser(user1);
        return "redirect:/user/view";
    }

    @RequestMapping("/pwdpage")
    public void pwdPage(HttpServletResponse response, Long id) {
        User user = userService.queryUserById(id);
        JsonMapper json = new JsonMapper();
        PageIOUtils.writeJson(response, json.toJson(user));
    }

    @RequestMapping("/editpwd")
    public void editPwd(HttpServletResponse response, Long id, String pwd0, String pwd1, String pwd2) {
        String result = userService.editPwd(id, pwd0, pwd1, pwd2);
        PageIOUtils.writeHtml(response, result);
    }

    @RequestMapping("/checkname")
    public void checkName(HttpServletResponse response, String name) {
        String result = userService.checkName(name);
        PageIOUtils.writeHtml(response, result);
    }
}
